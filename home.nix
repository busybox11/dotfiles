{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      home-manager
      hello
    ];

    username = "rain";
    homeDirectory = "/home/rain";

    stateVersion = "25.11";
  };
}
