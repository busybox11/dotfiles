# Graphical VM: Hyprland + Plasma, SDDM. No GNOME, TLP, or Sunshine.
{
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./graphical-common.nix ];

  services.displayManager.sddm.enable = true;

  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland
  ];
}
