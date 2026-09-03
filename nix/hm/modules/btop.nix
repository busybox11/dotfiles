{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isLinux then
        pkgs.btop.override {
          cudaSupport = true;
          rocmSupport = true;
        }
      else
        pkgs.btop;
    settings = {
      graph_symbol = "braille";
      gpu_mirror = true;
      theme_background = false;
      update_ms = 500;
    };
  };
}
