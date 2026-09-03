# Import only from darwin homeConfigurations (see lib.nix hmModulesFor).
{ ... }:
{
  imports = [
    ../modules/darwin
  ];
}
