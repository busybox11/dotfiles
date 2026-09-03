# Native TwintailLauncher (github:madebycli/twintail-nix).
#
# Imported only for hosts with features.twintail (see nix/hosts.nix).
{
  pkgs,
  twintail-nix,
  ...
}:
{
  home.packages = [
    twintail-nix.packages.${pkgs.system}.twintaillauncher
    pkgs.gamescope

    pkgs.tetrio-desktop
  ];
}
