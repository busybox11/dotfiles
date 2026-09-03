{
  pkgs,
  lib,
  nestedInNixOS ? false,
  ...
}:
{
  imports = [
    ../../common/nix-settings.nix
    ../modules
  ];

  # Standalone HM generates ~/.config/nix/nix.conf from nix.settings and
  # needs a package. Nested HM inherits this from NixOS.
  nix.package = lib.mkIf (!nestedInNixOS) pkgs.lix;
}
