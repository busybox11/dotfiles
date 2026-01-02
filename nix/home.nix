{ pkgs, username, ... }:
{
  imports = [
    ./modules/zsh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    packages = with pkgs; [
      hello
    ];

    stateVersion = "25.11";
  };

  programs.home-manager = {
    enable = true;
  };
}
