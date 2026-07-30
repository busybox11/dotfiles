# Merges flake-local config (nix/local.nix) into home-manager.
{ local, flakeHost, lib, ... }:
let
  hostLocal = (local.hosts or { }).${flakeHost} or { };
  localGhostty = local.programs.ghostty or { };
  hostGhostty = hostLocal.programs.ghostty or { };
  ghosttySettings = lib.mkMerge [
    (localGhostty.settings or { })
    (hostGhostty.settings or { })
  ];
in
{
  appearance = lib.mkMerge [
    {
      matugen.enable = lib.mkDefault true;
      wallpaper = lib.mkDefault "wallpapers/126660551_p0_cut.jpg";
    }
    (local.appearance or { })
    (hostLocal.appearance or { })
  ];

  programs.ghostty.settings = lib.mkIf (ghosttySettings != { }) ghosttySettings;
}
