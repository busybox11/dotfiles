{ pkgs }:
if pkgs.stdenv.hostPlatform.isLinux then
  pkgs.btop.override {
    cudaSupport = true;
    rocmSupport = true;
  }
else
  pkgs.btop
