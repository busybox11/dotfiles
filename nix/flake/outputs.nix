inputs@{
  self,
  deploy-rs,
  nixpkgs,
  ...
}:
let
  lib = nixpkgs.lib;
  hosts = import ../hosts.nix;

  local = import ../local.nix;

  flakeLib = import ./lib.nix {
    inherit inputs hosts local;
  };
  inherit (flakeLib) mkHome mkNixOS mkDarwinHome;

  nixosHosts = lib.filterAttrs (_: h: h.nixos or false) hosts;
  homeHosts = lib.filterAttrs (_: h: h.home or false) hosts;
  deployHosts = lib.filterAttrs (_: h: (h.nixos or false) && (h ? deploy) && (h.deploy ? ipv4)) hosts;
in
{
  nixosConfigurations = lib.mapAttrs (hostName: _host: mkNixOS hostName) nixosHosts;

  deploy.nodes = lib.mapAttrs (name: host: {
    hostname = host.deploy.hostname or host.deploy.ipv4;
    sshUser = "root";
    profiles.system = {
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${name};
    };
    remoteBuild = true;
  }) deployHosts;

  packages.x86_64-linux.devvm = self.nixosConfigurations.devvm.config.system.build.vm;

  homeConfigurations =
    lib.mapAttrs (
      name: cfg:
      mkHome (
        {
          flakeHost = name;
          nestedInNixOS = false;
        }
        // cfg
      )
    ) homeHosts
    // mkDarwinHome;
}
