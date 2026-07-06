{ lib, pkgs, ... }:
let
  machine = rec {
    hostName = "voidroid";
    username = "rain";
    dotfilesPath = "/home/${username}/.dotfiles";
  };

  wifiPowersave = pkgs.writeShellScript "wifi-powersave" ''
    for iface in $(${pkgs.iw}/bin/iw dev 2>/dev/null | ${pkgs.gnused}/bin/sed -n 's/^[[:space:]]*Interface //p'); do
      ${pkgs.iw}/bin/iw dev "$iface" set power_save "$1"
    done
  '';
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

  networking.useDHCP = lib.mkDefault true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEXbYlSOvJuaxsDejRybBkLQwbA18fhTE3j1oIb1cR4K" ];

  system.stateVersion = "26.05";

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${wifiPowersave} off"
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${wifiPowersave} on"
  '';
}
