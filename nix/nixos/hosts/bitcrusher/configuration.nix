{ lib, pkgs, ... }:
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
  
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime.offload.enable = lib.mkDefault false;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K" ];

  system.stateVersion = "26.05";
}

