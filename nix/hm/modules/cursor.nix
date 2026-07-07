{ pkgs, flakeHost, ... }:
let
  vscodeConfig = import ./vscode-config.nix { inherit pkgs flakeHost; };
in
{
  programs.cursor = {
    enable = true;
    package = pkgs.code-cursor;

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}
