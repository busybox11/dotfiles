# Standalone Linux HM only. Nested NixOS HM already has services.sunshine
# from graphical-laptop; a second user unit would fight it.
#
# Input emulation still needs host udev (sunshine's 60-sunshine.rules) and uinput.
{
  lib,
  pkgs,
  nestedInNixOS ? false,
  ...
}:
let
  enable = pkgs.stdenv.hostPlatform.isLinux && !nestedInNixOS;
in
{
  config = lib.mkIf enable {
    home.packages = [ pkgs.sunshine ];

    systemd.user.services.sunshine = {
      Unit = {
        Description = "Sunshine game stream host";
        PartOf = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = lib.getExe pkgs.sunshine;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
