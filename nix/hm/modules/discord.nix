{ pkgs, ... }:
let
  inherit (import ../chromium-features.nix) wrap;
in
{
  programs.equibop.enable = true;
  programs.equibop.package = wrap pkgs pkgs.equibop;
}