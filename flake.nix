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
      {

        apps = {
          duckVM = mkVM "duckVM";
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
