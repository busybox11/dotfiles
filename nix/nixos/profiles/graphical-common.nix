# Shared Hyprland + Plasma graphical stack. Laptop/VM profiles add their
# display manager, extra DEs, and power/portal policy on top.
{
  config,
  pkgs,
  kwin-effects-better-blur-dx,
  ...
}:
{
  imports = [ ../modules/chromium-policies.nix ];

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
  services.desktopManager.plasma6.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_ENABLE_FEATURES = "ElasticOverscroll,TouchpadOverscrollHistoryNavigation";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.libinput.enable = true;

  zramSwap.enable = true;

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  hardware.enableRedistributableFirmware = true;

  programs.obs-studio.enable = true;

  # v4l2loopback for OBS virtual camera — available via `modprobe v4l2loopback`
  # but not auto-loaded at boot.
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];

  environment.systemPackages = with pkgs; [
    libva-utils

    uwsm
    swaybg
    hyprsunset
    hyprlock
    hyprpolkitagent
    networkmanagerapplet
    swayosd
    eww
    vicinae
    pulseaudio
    pwvucontrol

    kwin-effects-better-blur-dx.packages.${pkgs.system}.default
  ];
}
