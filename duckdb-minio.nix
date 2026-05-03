{ writeShellScriptBin, duckdb }:

writeShellScriptBin "duckdb-minio" ''

  CMD="taskset -c 0 ${duckdb}/bin/duckdb -init ${./init.sql} $@"

  ${duckdb}/bin/duckdb -c "INSTALL httpfs;"
  sudo ip netns exec ns_client su -c "$CMD" $USER
''
