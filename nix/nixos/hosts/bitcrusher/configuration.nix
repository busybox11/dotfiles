{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/graphical-laptop.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
  ];
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  systemd.services.asus-dgpu-enable = {
    description = "Ensure ASUS dGPU is powered for nvidia/cardwire";
    wantedBy = [ "multi-user.target" ];
    before = [
      "display-manager.service"
      "cardwired.service"
    ];
    unitConfig.ConditionPathExists = "/sys/devices/platform/asus-nb-wmi/dgpu_disable";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "asus-dgpu-on" ''
        echo 0 > /sys/devices/platform/asus-nb-wmi/dgpu_disable
      '';
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # lspci: 01:00.0 NVIDIA, 06:00.0 AMD
      nvidiaBusId = "PCI:1:0:0";
      amdgpuBusId = "PCI:6:0:0";
    };
  };

  services.cardwired = {
    enable = true;
    settings = {
      auto_apply_gpu_state = true;
      battery_auto_switch = false;
    };
  };

  services.asusd.enable = true;

  services.udev.extraRules = ''
    KERNEL=="card[0-9]", KERNELS=="0000:06:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/amd-igpu"
    KERNEL=="card[0-9]", KERNELS=="0000:01:00.0", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/nvidia-dgpu"
  '';

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K"
  ];

  system.stateVersion = "26.05";
}
