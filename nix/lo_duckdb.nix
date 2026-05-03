{ writeShellScriptBin, duckdb }:

writeShellScriptBin "lo_duckdb" ''
  ${duckdb}/bin/duckdb -c "INSTALL httpfs;"
  taskset -c 0 ${duckdb}/bin/duckdb -init ${../sql/lo_init.sql} $@
''
