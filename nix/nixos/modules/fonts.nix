{ pkgs, ... }:
{
  fonts.packages = import ../../fonts/packages.nix { inherit pkgs; };
  fonts.fontconfig.enable = true;
}
