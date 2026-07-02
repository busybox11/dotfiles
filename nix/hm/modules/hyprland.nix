{ config, dotfilesPath, ... }:
{
  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/hypr";
}
