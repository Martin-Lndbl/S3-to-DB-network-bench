{ inputs, ... }:

final: _prev: {
  minio-server = _prev.callPackage ./minio-server.nix { };
  duckdb-minio = _prev.callPackage ./duckdb-minio.nix { };
  setup-minio = _prev.callPackage ./setup-minio.nix { };
}
