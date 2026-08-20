# Standalone Linux HM only. NixOS hosts already run services.sunshine from
# graphical-laptop; a second user unit would fight it.
#
# Input emulation still needs host udev (sunshine's 60-sunshine.rules) and uinput.
{
  lib,
  pkgs,
  flakeHost,
  hosts,
  ...
}:
let
  enable = pkgs.stdenv.hostPlatform.isLinux && !(builtins.hasAttr flakeHost hosts);
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
