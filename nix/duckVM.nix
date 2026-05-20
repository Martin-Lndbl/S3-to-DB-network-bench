{
  config,
  lib,
  pkgs,
  ...
}:
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
