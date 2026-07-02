{ config, pkgs, ... }:
{
  programs.firefox.enable = true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

  programs.google-chrome.enable = true;

  home.packages = with pkgs; [
    spotify
    moonlight-qt
  ];
}
