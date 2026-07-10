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

  # Prefer Ethernet over WiFi (lower route metric = higher priority).
  networking.networkmanager.ensureProfiles.profiles = {
    ethernet-priority = {
      connection = {
        id = "ethernet-priority";
        type = "ethernet";
        "match-device" = "interface-name:en*";
        autoconnect-priority = 10;
      };
      ipv4 = {
        method = "auto";
        "route-metric" = 100;
      };
      ipv6 = {
        method = "auto";
        "route-metric" = 100;
      };
    };
  };

  services.logind.settings.Login.HandleLidSwitch = "ignore";

  environment.systemPackages = with pkgs; [
    lm_sensors
    libva-utils
    waypipe
    xwayland-satellite
    xauth
  ];
  services.openssh.settings.StreamLocalBindMask = "0117";
}
