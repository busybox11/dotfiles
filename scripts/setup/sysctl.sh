#!/bin/bash

# syncs sysctl dotfiles with system
# will probably be managed by chezmoi at some point
# or maybe ill get motivated to migrate full time to nixos
# who knows..

for file in etc/sysctl.d/99-dotfiles-*.conf; do
    sudo cp $file /etc/sysctl.d/
done
