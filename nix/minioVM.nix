{
  config,
  lib,
  pkgs,
  ...
}:
let
  justfile = pkgs.writeTextFile {
    name = "justfile";
    text =
      # justfile
      ''
            
        setup:
          mkdir -p ~/minio-data

          sudo ip link set dev eth1 mtu 9000
          sudo ip addr add dev eth1 192.168.1.1/24
          sudo ip link set dev eth1 up


        run:
          minio server ~/minio-data --address '192.168.1.1:9000' --console-address '192.168.1.1:9001'
      '';
  };
in
{
  boot.kernelModules = [ "kvm-amd" ];
  boot.initrd.availableKernelModules = [ "iavf" ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.getty.autologinUser = "root";
  users.users.root.initialHashedPassword = "";

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 4;
      graphics = false;
      qemu.options = [
        "-device"
        "vfio-pci,host=c1:01.0,id=netvf0"
      ];
    };
  };

  system.activationScripts.justfile.text = ''
    ln -sf ${justfile} /root/justfile
  '';

  environment.systemPackages = with pkgs; [
    gdb
    perf
    gcc
    neovim
    pciutils
    minio
    duckdb
    just
  ];

  networking.firewall.allowedTCPPorts = [
    9000
    9001
  ];
  networking.hostName = "minioVM";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
