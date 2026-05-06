{ writeShellScriptBin, duckdb }:

writeShellScriptBin "nic_duckdb" ''

  CMD="taskset -c 0-63 ${duckdb}/bin/duckdb -init ${../sql/nic_init.sql} $@"

  ${duckdb}/bin/duckdb -c "INSTALL cache_httpfs from community;"
  sudo ip netns exec ns_client su -c "$CMD" $USER
''
