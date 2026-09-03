{
  pkgs,
  username,
  homeDirectory,
  ...
}:
let
  sharedPackages = import ./common-pkgs.nix { inherit pkgs; };
in
{
  imports = [
    ./profiles/common.nix
  ];

  home = {
    inherit username homeDirectory;

    packages = sharedPackages;

    stateVersion = "25.11";
  };

  programs.home-manager = {
    enable = true;
  };
}
