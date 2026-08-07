{ flakeHost, lib, ... }:
{
  imports = lib.optionals (builtins.elem flakeHost [
    "chaeri"
    # "realbox"
  ]) [ ./flatpak-twintail.nix ];
}
