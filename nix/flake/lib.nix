{
  inputs,
  hosts,
  infra,
  local,
}:
let
  inherit (inputs) nixpkgs home-manager self zen-browser nur apple-fonts nix-vscode-extensions;
  lib = nixpkgs.lib;

  overlays = [
    apple-fonts.overlays.default
    nur.overlays.default
    nix-vscode-extensions.overlays.default
  ];

  pkgsFor = system: import nixpkgs {
    inherit system;
    inherit overlays;
  };

  mkHome =
    {
      system,
      username,
      homeDirectory,
      dotfilesPath,
      flakeHost,
      extraModules ? [ ],
    }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;

      modules = [
        ../hm/default.nix
        ../hm/from-flake-local.nix
      ] ++ extraModules;

      extraSpecialArgs = {
        inherit self username homeDirectory dotfilesPath flakeHost local zen-browser nur hosts;
        fontsManagedByNixOS = builtins.hasAttr flakeHost hosts;
      };
    };

  mkNixOS = hostName:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit self hosts infra local zen-browser;
      };
      modules = [
        home-manager.nixosModules.home-manager
        ../nixos/hosts/${hostName}/configuration.nix
        { nixpkgs.overlays = overlays; }
      ];
    };

  mkDarwinHome =
    let
      localPath = ../hm/darwin-local.nix;
    in
    if builtins.pathExists localPath then
      let
        darwinLocal = import localPath;
      in
      lib.optionalAttrs (lib.hasSuffix "-darwin" darwinLocal.system) {
        darwin = mkHome {
          system = darwinLocal.system;
          username = darwinLocal.username;
          homeDirectory = darwinLocal.homeDirectory;
          dotfilesPath = darwinLocal.dotfilesPath;
          flakeHost = "darwin";
          extraModules = [
            ../hm/profiles/darwin.nix
          ];
        };
      }
    else
      { };
in
{
  inherit lib mkHome mkNixOS mkDarwinHome;
}
