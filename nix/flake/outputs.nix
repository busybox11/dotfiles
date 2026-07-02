inputs @ { self, deploy-rs, nixpkgs, ... }:
let
  lib = nixpkgs.lib;
  hosts = import ../nixos/hosts/map.nix;
  homeHosts = import ./home-hosts.nix;

  infraPath =
    if builtins.pathExists /etc/nixos/infra.nix then
      /etc/nixos/infra.nix
    else if builtins.pathExists ../infra.nix then
      ../infra.nix
    else
      ../infra.nix.example;
  infra = import infraPath;

  local = import ../local.nix;

  flakeLib = import ./lib.nix {
    inherit inputs hosts infra local;
  };
  inherit (flakeLib) mkHome mkNixOS mkDarwinHome;
in
{
  nixosConfigurations = lib.mapAttrs (_hostName: _host: mkNixOS _hostName) hosts;

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
  ) hosts;

  # deploy-rs README suggests deployChecks for all deploy-rs.lib systems; that pulls
  # x86_64-linux builds under `nix flake check` on Darwin. Re-enable selectively if you want.
  # checks.x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks self.deploy;

  homeConfigurations =
    lib.mapAttrs (name: cfg: mkHome ({ flakeHost = name; } // cfg)) homeHosts
    // mkDarwinHome;
}
