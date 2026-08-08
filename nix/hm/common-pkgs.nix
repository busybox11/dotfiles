{ pkgs }:
with pkgs;
[
  htop
  btop
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

  papirus-icon-theme

  coreutils-full
  brightnessctl

  ookla-speedtest

  # code
  nixfmt
  statix
  nixd
  opencode
  nodejs_latest
  pnpm
  react-native-debugger
  direnv

  # android platform tools (adb, fastboot)
  android-tools

  gh
  graphite-cli
]
