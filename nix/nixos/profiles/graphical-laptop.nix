{ pkgs, lib, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # programs.ssh.askPassword = lib.mkForce "${pkgs.plasma5Packages.ksshaskpass}/bin/ksshaskpass";
  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  services.printing.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.libinput.enable = true;
  services.power-profiles-daemon.enable = true;

  boot.kernel.sysctl = {
    "kernel.nmi_watchdog" = 0;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  zramSwap.enable = true;

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    libva-utils
    lm_sensors

    # Hyprland environment
    uwsm
    swaybg
    hyprsunset
    hyprlock
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    networkmanagerapplet
    swayosd
    eww
    vicinae
    pulseaudio
    pwvucontrol
  ];
}
