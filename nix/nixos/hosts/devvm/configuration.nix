{
  lib,
  pkgs,
  local,
  ...
}:
let
  machine = rec {
    hostName = "devvm";
    username = "rain";
    # Same path on Arch host and in the guest (9p/virtiofs share).
    dotfilesPath = "/home/${username}/dev/dotfiles_nixos";
  };

  hostLocal = (local.hosts or { }).${machine.hostName} or { };
  # Host-side path shared into the guest for live flake edits.
  flakeShareSource = hostLocal.flakeShareSource or machine.dotfilesPath;

  rainSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K";

  # use host QEMU for VirGL acceleration
  hostQemu = pkgs.runCommand "qemu-arch-host" {
    meta = {
      mainProgram = "qemu-system-x86_64";
      description = "Arch system QEMU (host GL stack)";
    };
  } ''
    mkdir -p $out/bin
    ln -sf /usr/bin/qemu-system-x86_64 $out/bin/qemu-system-x86_64
    ln -sf /usr/bin/qemu-img $out/bin/qemu-img
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/graphical-vm.nix
    (import ../../profiles/personal-machine.nix machine)
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.useDHCP = lib.mkDefault true;

  # Password: prefer hashedPassword in nix/local.nix (see hosts.devvm)
  # Else initialPassword "devvm" on first boot of a fresh disk; then `passwd` in guest
  # (persists on ./devvm.qcow2 across reboots)
  users.users.${machine.username} = {
    openssh.authorizedKeys.keys = [ rainSshKey ];
  }
  // (
    if hostLocal ? hashedPassword then
      { hashedPassword = hostLocal.hashedPassword; }
    else
      { initialPassword = "devvm"; }
  );
  users.users.root.openssh.authorizedKeys.keys = [ rainSshKey ];

  # Applied only when building `config.system.build.vm` (not a bare-metal install)
  virtualisation.vmVariant = {
    hardware.graphics.enable = true;
    boot.kernelModules = [ "virtio_gpu" ];

    virtualisation = {
      memorySize = 8192;
      cores = 4;
      diskSize = 40960;
      resolution = {
        x = 1920;
        y = 1080;
      };
      qemu = {
        package = hostQemu;
        options = [
          "-vga none"
          "-device virtio-vga-gl"
          "-display sdl,gl=on"
        ];
      };
      sharedDirectories = {
        dotfiles = {
          source = flakeShareSource;
          target = machine.dotfilesPath;
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
