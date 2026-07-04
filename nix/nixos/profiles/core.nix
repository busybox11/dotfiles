{ lib, pkgs, ... }:
{
  imports = [
    ../../common/nix-settings.nix
    ../modules/tailscale.nix
    ../modules/monitoring.nix
  ];

  nixpkgs.overlays = [ (final: prev: {
    inherit (prev.lixPackageSets.stable)
      nixpkgs-review
      nix-eval-jobs
      nix-fast-build
      colmena;
  }) ];
  nix.package = pkgs.lixPackageSets.stable.lix;

  time.timeZone = lib.mkDefault "Europe/Paris";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    pciutils
    usbutils
    neovim
    wget
    htop
    tree
    tmux
    wol
    fastfetch
    hyfetch
    ncurses
    xeyes
    ghostty.terminfo
  ];

  # universal kitty and ghostty terminfo handling
  environment.enableAllTerminfo = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.openssh.enable = lib.mkDefault true;
  
  # Key-only root SSH (no root password auth). Pair with users.users.root.openssh.authorizedKeys.* on each host.
  services.openssh.settings.PermitRootLogin = lib.mkDefault "prohibit-password";

  boot.supportedFilesystems = [ "ntfs" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
