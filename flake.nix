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
    {
      nixosConfigurations.duckVM = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./nix/duckVM.nix ];
      };

    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import ./nix/overlays.nix { inherit inputs; }) ];
        };

        mkVM = name: {
          type = "app";
          program = nixpkgs.lib.getExe self.nixosConfigurations.${name}.config.system.build.vm;
        };
      in
      rec {

        packages = {
          nic_minio = pkgs.nic_minio;
          lo_minio = pkgs.lo_minio;
          nic_duckdb = pkgs.nic_duckdb;
          lo_duckdb = pkgs.lo_duckdb;
        };

        apps = {
          duckVM = mkVM "duckVM";
          nic_minio = {
            type = "app";
            program = "${packages.nic_minio.outPath}/bin/nic_minio";
          };
          lo_minio = {
            type = "app";
            program = "${packages.lo_minio.outPath}/bin/lo_minio";
          };
          nic_duckdb = {
            type = "app";
            program = "${packages.nic_duckdb.outPath}/bin/nic_duckdb";
          };
          lo_duckdb = {
            type = "app";
            program = "${packages.lo_duckdb.outPath}/bin/lo_duckdb";
          };

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
            just

            python3Packages.pandas
            python3Packages.matplotlib
            python3Packages.seaborn
            pyright
          ];

        };
      }
    );
}
