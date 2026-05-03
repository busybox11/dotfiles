{ lib, ... }:
let
  machine = rec {
    hostName = "bookbox";
    username = "rain";
    dotfilesPath = "/home/${username}/build/dotfiles";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../nix/nixos/profiles/core.nix
    ../../nix/nixos/profiles/headless-laptop.nix
    (import ../../nix/nixos/personal-machine.nix machine)
  ];

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K" ];

  # bookbox is an intel laptop (ew)
  services.thermald.enable = true;

  system.stateVersion = "25.05";
}
