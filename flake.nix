{
  description = "rain personal dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, deploy-rs, self, ... }:
    let
      lib = nixpkgs.lib;
      hosts = import ./nix/hosts.nix;

      infraPath = ./nix/infra.nix;
      infra =
        if builtins.pathExists infraPath
        then import infraPath
        else import ./nix/infra.nix.example;

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
          pkgs = import nixpkgs { inherit system; };

          modules = [
            ./nix/home.nix
          ] ++ extraModules;
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
              extraModules = [
                ./nix/profiles/darwin.nix
              ];
            };
          }
        else
          { };
    in
    {
      deploy.nodes.bookbox = {
        hostname = hosts.bookbox.ethernet.ipv4;
        sshUser = "root";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.bookbox;
        };
        remoteBuild = true;
      };

      # deploy-rs README suggests deployChecks for all deploy-rs.lib systems; that pulls
      # x86_64-linux builds under `nix flake check` on Darwin. Re-enable selectively if you want.
      # checks.x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks self.deploy;

      nixosConfigurations.bookbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self hosts infra; };
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/bookbox/configuration.nix
        ];
      };

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
