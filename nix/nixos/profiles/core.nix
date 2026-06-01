{ lib, pkgs, ... }:
{
  imports = [
    ../modules/tailscale.nix
    ../modules/monitoring.nix
  ];

  time.timeZone = lib.mkDefault "UTC";
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

  environment.systemPackages = with pkgs; [
    vim
    neovim
    wget
    git
    htop
    tree
    tmux
    wol
    fastfetch
    hyfetch
    ncurses
    ghostty.terminfo
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  services.openssh.enable = lib.mkDefault true;
  
  # Key-only root SSH (no root password auth). Pair with users.users.root.openssh.authorizedKeys.* on each host.
  services.openssh.settings.PermitRootLogin = lib.mkDefault "prohibit-password";

  nixpkgs.config.allowUnfree = lib.mkDefault true;
  nix.settings.experimental-features = lib.mkDefault [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
