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
          overlays = [ (import ./nix/overlays.nix { inherit inputs; }) ];
        };
      in
      rec {
        packages.nic_minio = pkgs.nic_minio;
        packages.lo_minio = pkgs.lo_minio;
        packages.nic_duckdb = pkgs.nic_duckdb;
        packages.lo_duckdb = pkgs.lo_duckdb;

        apps.nic_minio = {
          type = "app";
          program = "${packages.nic_minio.outPath}/bin/nic_minio";
        };
        apps.lo_minio = {
          type = "app";
          program = "${packages.lo_minio.outPath}/bin/lo_minio";
        };
        apps.nic_duckdb = {
          type = "app";
          program = "${packages.nic_duckdb.outPath}/bin/nic_duckdb";
        };
        apps.lo_duckdb = {
          type = "app";
          program = "${packages.lo_duckdb.outPath}/bin/lo_duckdb";
        };
        devShell = pkgs.mkShell {

          buildInputs = with pkgs; [
            minio
            minio-client
            duckdb
            flamegraph
            btop
            bpftrace
            nload

            python3Packages.pandas
            python3Packages.matplotlib
            python3Packages.seaborn
            pyright
          ];

        };
      }
    );
}
