# OLED idle: dim, lock, then DPMS off. Imported via features.hypridle.
{
  lib,
  pkgs,
  ...
}:
let
  hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
  hyprlock = lib.getExe pkgs.hyprlock;
  brightnessctl = lib.getExe pkgs.brightnessctl;
  loginctl = "${pkgs.systemd}/bin/loginctl";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${hyprlock}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
        inhibit_sleep = 3;
      };

      listener = [
        {
          timeout = 120;
          on-timeout = "${brightnessctl} -s set 10%";
          on-resume = "${brightnessctl} -r";
        }
        {
          timeout = 240;
          on-timeout = "${loginctl} lock-session";
        }
        {
          # Don't leave hyprlock (screenshot + clock) on the OLED.
          timeout = 250;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
      ];
    };
  };
}
