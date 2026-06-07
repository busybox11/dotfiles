{ ... }:
{
  imports = [
    ../modules
  ];

  nixpkgs.config.allowUnfree = true;
}
