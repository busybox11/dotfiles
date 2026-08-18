{
  config,
  dotfilesPath,
  pkgs,
  ...
}:
{
  home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr";

  programs.hyprshot = {
    enable = true;
  };

  programs.quickshell = {
    enable = true;
  };
  home.file.".config/quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/quickshell";
  home.packages = with pkgs; [
    qt6.qt5compat
    wtype
  ];

  home.file."Pictures/wallpapers".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wallpapers";
}
