username:
{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  users.users.${username} = {
    extraGroups = [ "docker" ];
  };
}
