# Native TwintailLauncher (github:madebycli/twintail-nix).
#
# Replaces the former Flatpak install (flatpak-twintail.nix). The package is
# built from the official TwintailTeam .deb inside an FHS environment — no
# source build, no Flatpak sandbox. Launcher-managed state moves from the
# Flatpak data dir (~/.var/app/app.twintaillauncher.ttl) to the standard
# ~/.local/share/twintaillauncher.
{
  flakeHost,
  lib,
  pkgs,
  twintail-nix,
  ...
}:
{
  home.packages = lib.mkIf (builtins.elem flakeHost [ "chaeri" ]) [
    twintail-nix.packages.${pkgs.system}.twintaillauncher
    pkgs.gamescope
  ];
}
