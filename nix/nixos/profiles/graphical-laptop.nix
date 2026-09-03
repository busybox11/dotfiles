# Daily-driver laptop: Hyprland (default session) plus GNOME and Plasma.
{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./graphical-common.nix
    ../modules/sunshine.nix
  ];

  # Hyprland owns screencast/screenshot; GNOME FileChooser is Nautilus.
  xdg.portal = {
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
    };
  };

  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "hyprland-uwsm";

  services.desktopManager.gnome.enable = true;

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  services.printing.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings.START_CHARGE_THRESH_BAT0 = 85;

  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  environment.systemPackages = with pkgs; [
    lm_sensors
    nvtopPackages.full
    libsecret
    seahorse
  ];

  security.pam.services = {
    sudo.nodelay = true;

    gdm.enableGnomeKeyring = true;
    hyprlock.enableGnomeKeyring = true;
  };
}
