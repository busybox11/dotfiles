# Import only from darwin homeConfigurations (see flake.nix extraModules).
{ ... }:
{
  imports = [
    ./screencapture.nix
    ./yabai-skhd.nix
    ./bluetooth.nix
  ];
}
