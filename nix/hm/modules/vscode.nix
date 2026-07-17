{ pkgs, flakeHost, vscode-server, ... }:
let
  vscodeConfig = import ./vscode-config.nix { inherit pkgs flakeHost; };
in
{
  # Import the module directly using the path to avoid using the flake's `homeModules.default` if it triggers recursion
  imports = [ "${vscode-server}/modules/vscode-server/home.nix" ];

  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_24;
    installPath = [
      "$HOME/.vscode-server"
      "$HOME/.code-server"
      "$HOME/.cursor-server"
    ];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}

