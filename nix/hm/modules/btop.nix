{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = true;
      rocmSupport = true;
    };
    settings = {
      graph_symbol = "braille";
      gpu_mirror = true;
      theme_background = false;
      update_ms = 500;
    };
  };
}
