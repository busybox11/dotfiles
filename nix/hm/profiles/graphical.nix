# Desktop / GUI Home Manager modules. Not imported on headless or Darwin.
{ ... }:
{
  imports = [
    ../modules/plasma-better-blur.nix
    ../modules/gui.nix
    ../modules/hyprland.nix
    ../modules/hyprcursor.nix
    ../modules/zen
    ../modules/helium.nix
    ../modules/discord.nix
    ../modules/playerctl.nix
    ../modules/cider.nix
    ../modules/sunshine.nix
    ../modules/vscode-matugen-theme.nix
  ];
}
