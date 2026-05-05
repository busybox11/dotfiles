# HM + primary user. flakeHost follows networking.hostName (= hostName).
{
  hostName,
  username,
  dotfilesPath ? "/home/${username}/dev/dotfiles",
  homeDirectory ? "/home/${username}",
}:
{ self, hosts, ... }:
{
  networking.hostName = hostName;

  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    extraGroups = [ "sudo" "wheel" "networkmanager" ];
  };

  home-manager.extraSpecialArgs = {
    inherit hosts self username homeDirectory dotfilesPath;
    flakeHost = hostName;
  };

  home-manager.users.${username}.imports = [ ../../hm/default.nix ];
}
