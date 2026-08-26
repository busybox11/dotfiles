{ pkgs }:
with pkgs;
[
  htop
  usbtop
  powertop

  eza
  bat
  ripgrep
  fd
  fzf
  eza
  tree
  tmux
  file

  papirus-icon-theme

  coreutils-full
  brightnessctl

  ookla-speedtest

  # code
  nixfmt
  statix
  nixd
  opencode
  opencode2
  nodejs_latest
  pnpm
  bun
  direnv

  # android platform tools (adb, fastboot)
  android-tools

  gh
  graphite-cli
]
