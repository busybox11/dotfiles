# Loaded only via profiles/darwin.nix
{ config, ... }:
{
  targets.darwin.defaults."com.apple.screencapture" = {
    location = "${config.home.homeDirectory}/Pictures/Screenshots";
    target = "file";
  };

  home.file."Pictures/Screenshots/.keep".text = "";
}
