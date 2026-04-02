{ pkgs, username, homeDirectory, ... }:
let
  sharedPackages = import ./common-pkgs.nix { inherit pkgs; };
in
{
  imports = [
    ./modules
  ];

  home = {
    inherit username homeDirectory;

    packages = sharedPackages ++ [
      pkgs.hello
    ];

    stateVersion = "25.11";
  };

  programs.home-manager = {
    enable = true;
  };
}
