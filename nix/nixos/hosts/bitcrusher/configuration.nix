{
  lib,
  pkgs,
  config,
  ...
}:
let
  machine = rec {
    hostName = "bitcrusher";
    username = "rain";
    dotfilesPath = "/home/${username}/.dotfiles";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/graphical-laptop.nix
    (import ../../profiles/personal-machine.nix machine)
  ];

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
  ];
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  systemd.services.asus-dgpu = {
    description = "ASUS dGPU power gate (asus-nb-wmi)";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    unitConfig.ConditionPathExists = "/sys/devices/platform/asus-nb-wmi/dgpu_disable";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "asus-dgpu-off" ''
        echo 1 > /sys/devices/platform/asus-nb-wmi/dgpu_disable
      '';
    };
  };

  specialisation.nvidia.configuration = {
    system.nixos.tags = [ "nvidia" ];

    # EC sometimes keeps dgpu_disable=1 across reboot
    # clear it before the nvidia stack binds
    systemd.services.asus-dgpu.serviceConfig.ExecStart = lib.mkForce (
      pkgs.writeShellScript "asus-dgpu-on" ''
        echo 0 > /sys/devices/platform/asus-nb-wmi/dgpu_disable
      ''
    );

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
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K"
  ];

  system.stateVersion = "26.05";
}
