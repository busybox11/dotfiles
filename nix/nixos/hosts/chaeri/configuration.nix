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
  # PSR. The nvidia specialisation below overrides this with 0x610
  boot.kernelParams = [
    "amdgpu.dcdebugmask=0x400"
  ];

  boot.blacklistedKernelModules = [
    "nouveau"
    "nvidiafb"
  ];
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  specialisation.nvidia.configuration = {
    system.nixos.tags = [ "nvidia" ];

    # 0x610 = disable PSR + PSR-SU + Replay: locked true 120Hz on the iGPU
    # Replaces the default 0x400 (which can sag below 120Hz under PSR)
    boot.kernelParams = lib.mkForce [
      "amdgpu.dcdebugmask=0x610"
    ];

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
        # iGPU is confirmed at 65:00.0. nvidiaBusId must be set from
        # `lspci | grep -i nvidia` when dGPU will work (ouch)
        nvidiaBusId = "PCI:1:0:0"; # TODO: verify once dGPU is enabled in BIOS
        amdgpuBusId = "PCI:65:0:0";
      };
    };
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
