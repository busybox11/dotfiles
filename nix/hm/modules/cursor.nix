{ pkgs, ... }:
let
  vscodeConfig = import ./vscode-config.nix { inherit pkgs; };
in
{
  programs.cursor = {
    enable = true;
    package = pkgs.cursor;

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}
