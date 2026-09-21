{ pkgs, ... }:
let
  btop = import ../../common/btop-package.nix { inherit pkgs; };
in
{
  # Intel iGPU (and CPU RAPL) metrics go through perf events.
  security.wrappers.btop = {
    owner = "root";
    group = "root";
    source = "${btop}/bin/btop";
    capabilities = "cap_perfmon+ep";
  };
}
