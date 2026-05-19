{ ... }:

final: _prev: {
  nic_minio = _prev.callPackage ./nic_minio.nix { };
  lo_minio = _prev.callPackage ./lo_minio.nix { };
  nic_duckdb = _prev.callPackage ./nic_duckdb.nix { };
  lo_duckdb = _prev.callPackage ./lo_duckdb.nix { };
}
