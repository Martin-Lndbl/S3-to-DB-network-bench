{ writeShellScriptBin, duckdb }:

writeShellScriptBin "nic_duckdb" ''

  CMD="taskset -c 0 ${duckdb}/bin/duckdb -init ${../sql/nic_init.sql} $@"

  ${duckdb}/bin/duckdb -c "INSTALL httpfs;"
  sudo ip netns exec ns_client su -c "$CMD" $USER
''
