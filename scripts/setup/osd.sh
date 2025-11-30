#!/bin/bash

# service
sudo systemctl enable --now swayosd-libinput-backend.service

# verify ddcutil is installed
if ! command -v ddcutil &> /dev/null; then
    echo "installing ddcutil"
    yay -S ddcutil
fi

# verify user is in the video group
if ! id -Gn | grep -q "video"; then
    echo "adding user to video group"
    sudo usermod -aG video $USER
fi