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
  
  coreutils-full

  ookla-speedtest

  # code
  nixfmt
  statix
  nixd
  opencode

  # android platform tools (adb, fastboot)
  android-tools

  graphite-cli
]
