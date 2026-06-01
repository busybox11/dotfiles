{ lib, ... }:
let
  machine = rec {
    hostName = "lovefield";
    username = "rain";
    dotfilesPath = "/home/${username}/build/dotfiles";
  };
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/core.nix
    ../../profiles/headless-laptop.nix
    (import ../../profiles/personal-machine.nix machine)
    (import ../../modules/music-stack.nix machine.username)
  ];

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K" ];

  # lovefield is an intel laptop (ew)
  services.thermald.enable = true;

  # custom internal services
  services.musicStack.enable = true;

  system.stateVersion = "25.05";
}
