{
  config,
  lib,
  pkgs,
  dotfilesPath,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  
  useMatugenTheme =
    config.appearance.matugen.enable
    && config.appearance.wallpaper != null;
in
{
  config = {
    # custom-shader paths are relative to $XDG_CONFIG_HOME/ghostty/
    xdg.configFile = {
      "ghostty/shaders".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty/shaders";
      "ghostty/themes/.keep".text = "";
    };

    programs.ghostty = {
      # macOS app is installed outside nix; Linux uses the nix package
      package = if isDarwin then null else pkgs.ghostty;
      enable = true;

      settings = lib.mkMerge [
        {
          background-opacity = 0.8;
          custom-shader = "shaders/cursor_warp_custom.glsl";
          shell-integration-features = "ssh-env,ssh-terminfo";
        }
        
        (lib.optionalAttrs useMatugenTheme {
          theme = "Matugen";
        })
      ];
    };
  };
}
