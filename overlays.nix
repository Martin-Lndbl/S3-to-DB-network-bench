{ inputs, ... }:

final: _prev: {
  minio-server = _prev.callPackage ./minio-server.nix { };
  duckdb-minio = _prev.callPackage ./duckdb-minio.nix { };
}
