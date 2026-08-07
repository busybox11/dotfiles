{
  config,
  lib,
  pkgs,
  ...
}:
let
  machine = rec {
    hostName = "chaeri";
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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # amdgpu.dcdebugmask=0x400 disables Panel Replay only (keeps PSR for battery)
  # Fixes the DC 3.2.378 Panel Replay hang; refresh may sag below 120Hz under
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x400"
  ];

  # nvidia-open instead of nouveau; the nvidia module also blacklists
  # nouveau/nvidiafb etc
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
      nvidiaBusId = "PCI:64:0:0";
      amdgpuBusId = "PCI:65:0:0";
    };
  };

  boot.kernelModules = lib.mkForce [ "kvm-amd" ];

  specialisation.nvidia.configuration = {
    system.nixos.tags = [ "nvidia" ];

    # 0x610 = disable PSR + PSR-SU + Replay: locked true 120Hz on the iGPU
    # Replaces the default 0x400 (which can sag below 120Hz under PSR)
    boot.kernelParams = lib.mkForce [
      "amdgpu.dcdebugmask=0x610"
    ];

    boot.kernelModules = lib.mkForce [
      "nvidia"
      "nvidia_modeset"
      "nvidia_drm"
      "nvidia_uvm"
    ];
  };

  services.supergfxd = {
    enable = true;
    settings = {
      mode = "hybrid";
    };
  };

  services.asusd.enable = true;

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K"
  ];

  system.stateVersion = "26.05";
}
