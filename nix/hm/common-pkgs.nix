{ pkgs }:
with pkgs;
[
  htop
  eza
  bat
  ripgrep
  fd
  fzf
  eza
  tree
  tmux

  # fonts
  cascadia-code

  # code
  nixfmt
  nixd

  # android platform tools (adb, fastboot)
  android-tools
]
