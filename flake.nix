{
  description = "rain personal dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, self, ... }:
    let
      lib = nixpkgs.lib;

      mkHome =
        {
          system,
          username,
          homeDirectory,
          dotfilesPath,
          flakeHost,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };

          modules = [
            ./nix/home.nix
          ];
          extraSpecialArgs = {
            inherit self username homeDirectory dotfilesPath flakeHost;
          };
        };

      # builtins.currentSystem is unset under flake eval — system comes from darwin-local.nix
      homeConfigurationsDarwin =
        let
          localPath = ./nix/darwin-local.nix;
        in
        if builtins.pathExists localPath then
          let
            l = import localPath;
          in
          lib.optionalAttrs (lib.hasSuffix "-darwin" l.system) {
            darwin = mkHome {
              system = l.system;
              username = l.username;
              homeDirectory = l.homeDirectory;
              dotfilesPath = l.dotfilesPath;
              flakeHost = "darwin";
            };
          }
        else
          { };
    in
    {
      homeConfigurations = {
        realbox = mkHome {
          system = "x86_64-linux";
          username = "rain";
          homeDirectory = "/home/rain";
          dotfilesPath = "/home/rain/dev/dotfiles";
          flakeHost = "realbox";
        };
        powerbox = mkHome {
          system = "x86_64-linux";
          username = "busybox";
          homeDirectory = "/home/busybox";
          dotfilesPath = "/home/busybox/dev/dotfiles";
          flakeHost = "powerbox";
        };
      } // homeConfigurationsDarwin;
    };
}
