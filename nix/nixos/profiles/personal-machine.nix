# HM + primary user. flakeHost follows networking.hostName (= hostName).
{
  hostName,
  username,
  dotfilesPath ? "/home/${username}/dev/dotfiles",
  homeDirectory ? "/home/${username}",
}:
{ self, hosts, local, pkgs, zen-browser, ... }:
{
  imports = [
    ../modules/fonts.nix
    (import ../modules/superbird.nix username)
    (import ../modules/docker.nix username)
  ];

  networking.hostName = hostName;

  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    extraGroups = [ "sudo" "wheel" "networkmanager" "video" "audio" ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit hosts local self username homeDirectory dotfilesPath zen-browser;
    flakeHost = hostName;
    fontsManagedByNixOS = builtins.hasAttr hostName hosts;
  };

  home-manager.users.${username} = {
    imports = [
      ../../hm/default.nix
      ../../hm/from-flake-local.nix
    ];
    home.packages = [ pkgs.home-manager ];
  };
}
