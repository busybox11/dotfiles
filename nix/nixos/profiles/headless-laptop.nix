{ pkgs, ... }:
{
  # Headless server laptop: no lid action, blank console, keep panel off, auto-reboot on hang.
  boot.kernelParams = [
    "consoleblank=300"
    "video=eDP-1:d" # disconnect internal panel; GPU still available for VA-API/GL
  ];

  boot.kernelModules = [ "iTCO_wdt" ];

  systemd.settings.Manager = {
    RuntimeWatchdogSec = "60s";
    RebootWatchdogSec = "10min";
    WatchdogDevice = "/dev/watchdog0";
  };

  # Compressed RAM swap — no disk wear; enough headroom for remote-plasma OOM pressure.
  zramSwap.enable = true;

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  networking.networkmanager.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  environment.systemPackages = with pkgs; [
    lm_sensors
    libva-utils
  ];
}
