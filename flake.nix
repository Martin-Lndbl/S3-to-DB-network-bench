{
  description = "MinIO flake";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import ./overlays.nix { inherit inputs; }) ];
        };
      in
      rec {
        packages.minio-server = pkgs.minio-server;
        packages.duckdb-minio = pkgs.duckdb-minio;
        apps.minio-server = {
          type = "app";
          program = "${packages.minio-server.outPath}/bin/minio-server";
        };
        apps.duckdb-minio = {
          type = "app";
          program = "${packages.duckdb-minio.outPath}/bin/duckdb-minio";
        };
        devShell = pkgs.mkShell {

          buildInputs = with pkgs; [
            minio
            minio-client
            duckdb
            btop
          ];

        };
      }
    );
}
