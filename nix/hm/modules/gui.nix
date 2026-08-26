{ config, pkgs, ... }:
let
  inherit (import ../chromium-features.nix) features flag wrap;
in
{
  programs.firefox.enable = true;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

  programs.google-chrome.enable = true;
  programs.google-chrome.commandLineArgs = [ flag ];

  programs.obsidian.enable = true;

  home.sessionVariables.ELECTRON_ENABLE_FEATURES = features;

  home.packages = [
    (wrap pkgs pkgs.spotify)
    pkgs.moonlight-qt
  ];
}
