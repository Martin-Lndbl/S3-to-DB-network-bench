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
          sudo ip link set dev eth1 mtu 9000
          sudo ip addr add dev eth1 192.168.1.2/24
          sudo ip link set dev eth1 up

          mc alias set 'myminio' 'http://192.168.1.1:9000' 'minioadmin' 'minioadmin'

        ping:
          mc ping myminio
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
        "vfio-pci,host=c1:11.0,id=netvf0"
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
    minio-client
    duckdb
    just
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";
}
