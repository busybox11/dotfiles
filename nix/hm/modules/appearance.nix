{
  config,
  lib,
  pkgs,
  dotfilesPath,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  resolveWallpaper =
    value:
    if value == null then
      null
    else if builtins.isPath value then
      value
    else
      let
        s = toString value;
      in
      if lib.hasPrefix "/" s then
        s
      else
        "${dotfilesPath}/${s}";
in
{
  options.appearance = {
    wallpaper = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
      description = ''
        Wallpaper for the desktop and matugen.
        Absolute path, or a string relative to the dotfiles checkout (e.g. wallpapers/foo.jpg).
      '';
    };

    matugen = {
      enable = lib.mkEnableOption "matugen theme generation from appearance.wallpaper";

      mode = lib.mkOption {
        type = lib.types.enum [
          "light"
          "dark"
        ];
        default = "dark";
      };

      configFile = lib.mkOption {
        type = lib.types.str;
        default =
          if isDarwin then
            "darwin.toml"
          else
            "config.toml";
        description = "Matugen config basename under ~/.config/matugen/";
      };
    };
  };

  config =
    let
      wallpaper = resolveWallpaper config.appearance.wallpaper;
    in
    {
      home.packages = lib.mkIf config.appearance.matugen.enable [ pkgs.matugen ];

      home.file.".config/matugen".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/matugen";

      home.activation.appearanceMatugen = lib.hm.dag.entryAfter [ "linkGeneration" ] (
        if wallpaper == null || !config.appearance.matugen.enable then
          "exit 0"
        else
          let
            matugenConfigFile = config.appearance.matugen.configFile;
            matugenMode = config.appearance.matugen.mode;
            matugenConfig = "${dotfilesPath}/config/matugen/${matugenConfigFile}";
          in
        ''
          run ${pkgs.writeShellScript "matugen-from-wallpaper" ''
            set -euo pipefail
            wallpaper=${lib.escapeShellArg (toString wallpaper)}
            config=${lib.escapeShellArg matugenConfig}
            if [ ! -f "$wallpaper" ]; then
              echo "appearance: wallpaper not found: $wallpaper" >&2
              exit 1
            fi
            if [ ! -f "$config" ]; then
              echo "appearance: matugen config not found: $config" >&2
              exit 1
            fi
            mkdir -p "''${HOME}/.config/ghostty/themes"
            ${lib.getExe pkgs.matugen} image "$wallpaper" -c "$config" -m ${matugenMode} -q --source-color-index 0
          ''}
        ''
    );

      home.activation.appearanceWallpaper = lib.hm.dag.entryAfter [ "appearanceMatugen" ] (
        if wallpaper == null || !isDarwin then
          "exit 0"
        else
        ''
          run ${pkgs.writeShellScript "set-darwin-wallpaper" ''
            set -euo pipefail
            export PATH="/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"
            /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${wallpaper}\""
          ''}
        ''
    );

    };
}
