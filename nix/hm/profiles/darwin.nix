# Import only from darwin homeConfigurations (see flake.nix extraModules).
{ ... }:
{
  imports = [
    ../modules/yabai-skhd.nix
  ];
}
