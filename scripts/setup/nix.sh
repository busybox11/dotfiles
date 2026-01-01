#!/usr/bin/env bash

yay -Sy nix

sudo systemctl enable --now nix-daemon
sudo usermod -aG nixuser $USER

# nixpkgs bleeding edge
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

# home manager
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

nix-channel --update
