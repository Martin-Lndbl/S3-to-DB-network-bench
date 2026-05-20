runner := "taskset -c 64-95"

ssd := "nvme2n1"
servernic := "enp193s0f0np0"
clientnic := "enp193s0f1np1"

ns_server := "ns_server"
ns_client := "ns_client"

duckdb_extention := "httpfs"

args := ""

# Setup network interfaces, namespaces and mountpoints
setup:
  #!/usr/bin/env bash
  mkdir -p $HOME/minio-data
  mountpoint -q ~/minio-data || sudo mount /dev/{{ssd}} ~/minio-data
  sudo chown -R $USER $HOME/minio-data

  sudo modprobe ice
  sudo modprobe vfio-pci

  echo 0 | sudo tee /sys/class/net/{{clientnic}}/device/sriov_numvfs
  echo 1 | sudo tee /sys/class/net/{{clientnic}}/device/sriov_numvfs
  VF_PCI_ADDR=$(basename "$(readlink /sys/class/net/{{clientnic}}/device/virtfn0)")
  echo "${VF_PCI_ADDR}" | sudo tee /sys/bus/pci/devices/${VF_PCI_ADDR}/driver/unbind
  echo "vfio-pci" | sudo tee /sys/bus/pci/devices/${VF_PCI_ADDR}/driver_override > /dev/null
  echo "${VF_PCI_ADDR}" | sudo tee /sys/bus/pci/drivers_probe > /dev/null

  sudo ip netns add {{ns_server}}
  sudo ip link set {{servernic}} netns {{ns_server}}
  sudo ip netns exec {{ns_server}} ip link set dev {{servernic}} mtu 9000
  sudo ip netns exec {{ns_server}} ip addr add dev {{servernic}} 192.168.1.1/24
  sudo ip netns exec {{ns_server}} ip link set dev {{servernic}} up

  sudo ip netns add {{ns_client}}
  sudo ip link set {{clientnic}} netns {{ns_client}}
  sudo ip netns exec {{ns_client}} ip link set dev {{clientnic}} mtu 9000
  sudo ip netns exec {{ns_client}} ip addr add dev {{clientnic}} 192.168.1.2/24
  sudo ip netns exec {{ns_client}} ip link set dev {{clientnic}} up


# Unmount data dir and return the network interfaces to their default form
clean:
  #!/usr/bin/env bash
  sudo umount ~/minio-data
  sudo ip netns delete {{ns_server}}
  sudo ip netns delete {{ns_client}}
  echo 0 | sudo tee /sys/class/net/{{clientnic}}/device/sriov_numvfs

# Run a minio server in the local network
minio_local:
  #!/usr/bin/env bash
  {{runner}} minio server ~/minio-data --address 'localhost:9000' --console-address 'localhost:9001'

# Run a minio server in a network namespace
minio_netns:
  #!/usr/bin/env bash
  CMD="{{runner}} $(which minio) server ~/minio-data --address '192.168.1.1:9000' --console-address '192.168.1.1:9001'"
  sudo ip netns exec {{ns_server}} su -c "$CMD" $USER

# Run a duckdb instance in the local network
duckdb_local:
  #!/usr/bin/env bash
  duckdb -c "INSTALL {{duckdb_extention}};"
  {{runner}} duckdb -init ./sql/lo_init.sql {{args}}

# Run a duckdb instance in a network namespace
duckdb_netns:
  #!/usr/bin/env bash
  CMD="{{runner}} $(which duckdb) -init ./sql/nic_init.sql {{args}}"
  duckdb -c "INSTALL {{duckdb_extention}};"
  sudo ip netns exec {{ns_client}} su -c "$CMD" $USER

# Attach nload to the server side nic interface
monitor:
  #!/usr/bin/env bash
  sudo ip netns exec {{ns_server}} nload {{servernic}}  

# Run a VM with an virtual nic attached
duckVM:
  #!/usr/bin/env bash
  {{runner}} sudo nix run .#duckVM
