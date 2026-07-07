{ pkgs, flakeHost, ... }:
let
  vscodeConfig = import ./vscode-config.nix { inherit pkgs flakeHost; };
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}

