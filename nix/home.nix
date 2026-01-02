{ pkgs, username, ... }:
let
  sharedPackages = import ./common-pkgs.nix { inherit pkgs; };
in
{
  imports = [
    ./modules/zsh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = sharedPackages ++ [
      pkgs.hello
    ];

    stateVersion = "25.11";
  };

  programs.home-manager = {
    enable = true;
  };
}
