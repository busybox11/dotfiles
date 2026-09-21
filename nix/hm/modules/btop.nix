{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package = import ../../common/btop-package.nix { inherit pkgs; };
    settings = {
      graph_symbol = "braille";
      gpu_mirror = true;
      theme_background = false;
      update_ms = 500;
    };
  };
}
