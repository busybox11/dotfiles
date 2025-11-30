#!/bin/bash

# verify pkgfile is installed
if ! command -v pkgfile &> /dev/null; then
    echo "installing pkgfile"
    yay -S pkgfile
fi

# enable and start pkgfile-update.timer
echo "enabling and starting pkgfile update timer"
sudo systemctl enable --now pkgfile-update.timer
