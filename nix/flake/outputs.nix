inputs @ { self, deploy-rs, nixpkgs, ... }:
let
  lib = nixpkgs.lib;
  hosts = import ../nixos/hosts/map.nix;
  homeHosts = import ./home-hosts.nix;

  local = import ../local.nix;

  flakeLib = import ./lib.nix {
    inherit inputs hosts local;
  };
  inherit (flakeLib) mkHome mkNixOS mkDarwinHome;
in
{
  nixosConfigurations = lib.mapAttrs (_hostName: _host: mkNixOS _hostName) hosts;

  # Hosts with `deploy = false` (e.g. devvm) stay in nixosConfigurations only
  deploy.nodes = lib.mapAttrs (
    name: host:
    {
      hostname = host.ethernet.ipv4;
      sshUser = "root";
      profiles.system = {
        user = "root";
        path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${name};
      };
      remoteBuild = true;
    }
  ) (lib.filterAttrs (_: host: host.deploy or true) hosts);

  packages.x86_64-linux.devvm = self.nixosConfigurations.devvm.config.system.build.vm;

  homeConfigurations =
    lib.mapAttrs (name: cfg: mkHome ({ flakeHost = name; } // cfg)) homeHosts
    // mkDarwinHome;
}
