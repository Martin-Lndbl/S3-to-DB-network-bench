import os
import subprocess
import re
import csv
import sys
import time
import signal
from collections import defaultdict
from queue import Queue, Empty
from threading  import Thread

ON_POSIX = 'posix' in sys.builtin_module_names

def enqueue_output(out, queue):
    for line in iter(out.readline, b''):
        queue.put(line)
    out.close()

# List of commands with optional service start command (name, command, outfile, service_command, service_command_wait_for_line)
# commands = [
#     ("filesystem", "nix run .#lo_duckdb -- -f sql/tpch/fs_09.sql", "tpch09.csv", None, None),
#     ("filesystem", "nix run .#lo_duckdb -- -f sql/tpch/fs_11.sql", "tpch11.csv", None, None),
#     ("loopback", "nix run .#lo_duckdb -- -f sql/tpch/s3_09.sql", "tpch09.csv", "nix run .#lo_minio", "Docs: https://docs.min.io"),
#     ("loopback", "nix run .#lo_duckdb -- -f sql/tpch/s3_11.sql", "tpch11.csv", "nix run .#lo_minio", "Docs: https://docs.min.io"),
#     ("network card", "nix run .#nic_duckdb -- -f sql/tpch/s3_09.sql", "tpch09.csv", "nix run .#nic_minio", "Docs: https://docs.min.io"),
#     ("network card", "nix run .#nic_duckdb -- -f sql/tpch/s3_11.sql", "tpch11.csv", "nix run .#nic_minio", "Docs: https://docs.min.io"),
# ]

TCPHQUERIES = range(1, 23)

commands = [
    ("filesystem", f"nix run .#lo_duckdb -- -f sql/tpch/fs_{i:02d}.sql", f"tpch{i:02d}.csv", None, None) 
    for i in TCPHQUERIES
] + [
    ("loopback", f"nix run .#lo_duckdb -- -f sql/tpch/s3_{i:02d}.sql", f"tpch{i:02d}.csv", "nix run .#lo_minio", "Docs: https://docs.min.io") 
    for i in TCPHQUERIES
] + [
    ("network card", f"nix run .#nic_duckdb -- -f sql/tpch/s3_{i:02d}.sql", f"tpch{i:02d}.csv", "nix run .#nic_minio", "Docs: https://docs.min.io")
    for i in TCPHQUERIES
]

runtime_pattern = re.compile(r"Run Time \(s\):\s*real\s+([\d\.]+)\s+user\s+([\d\.]+)\s+sys\s+([\d\.]+)")
runtimes_by_outfile = defaultdict(list)

ITERATIONS = 1

for name, command, outfile, service_command, wait_for_line in commands:
    print(f"Executing command: '{command}' with output file: {outfile}")

    killpid = None
    service_process = None
    if service_command:
        print(f"Running {service_command}")
        service_process = subprocess.Popen(service_command, shell=True, stdout=subprocess.PIPE, close_fds=ON_POSIX)
        killpid = service_process.pid
        q = Queue()
        t = Thread(target=enqueue_output, args=(service_process.stdout, q))
        t.daemon = True
        t.start()

        while(True):
            try:  outbytes = q.get(timeout=.1)
            except Empty:
                continue
            else:
                outstr = outbytes.decode('utf-8')
                if not wait_for_line or wait_for_line in outstr:
                    break;
                match = re.search(r"TOKILL:\s*(\d+)", outstr)
                if match: 
                    killpid = int(match.group(1))

    print(f"Starting measurement loop")
    for i in range(ITERATIONS):
        start_time = time.time()
        
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        match = runtime_pattern.search(result.stdout)
        if match:
            real_time = float(match.group(1))
            user_time = float(match.group(2))
            sys_time = float(match.group(3))
            runtimes_by_outfile[outfile].append([name, i+1, real_time, user_time, sys_time])
        else:
            print(f"Error parsing runtime from attempt {i+1} for command: {name}")
        
        print(f"Run {i+1} for command '{name}' completed.")

    if service_command and service_process and killpid:
        print(f"Stopping {service_command}")
        os.kill(killpid, signal.SIGINT)
        service_process.wait()


for outfile, runtimes in runtimes_by_outfile.items():
    with open(outfile, mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["Command Name", "Run", "Real Time (s)", "User Time (s)", "Sys Time (s)"])
        for runtime in runtimes:
            writer.writerow(runtime)
    
    print(f"Runtime measurements saved to '{outfile}'.")
