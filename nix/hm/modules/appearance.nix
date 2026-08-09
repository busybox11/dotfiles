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
      if lib.hasPrefix "/" s then s else "${dotfilesPath}/${s}";
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
        default = if isDarwin then "darwin.toml" else "config.toml";
        description = "Matugen config basename under ~/.config/matugen/";
      };
    };
  };

  config =
    let
      wallpaper = resolveWallpaper config.appearance.wallpaper;
      dark = config.appearance.matugen.mode == "dark";
      gtkThemeName = if dark then "adw-gtk3-dark" else "adw-gtk3";
      iconThemeName = if dark then "Papirus-Dark" else "Papirus-Light";
      colorScheme = config.appearance.matugen.mode;
      kwriteconfig6 = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
    in
    {
      home.packages = lib.mkIf config.appearance.matugen.enable [ pkgs.matugen ];

      home.file.".config/matugen".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/matugen";

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
              if ! timeout 60 ${lib.getExe pkgs.matugen} image "$wallpaper" -c "$config" -m ${matugenMode} -q --source-color-index 0; then
                echo "appearance: matugen timed out or failed" >&2
              fi
            ''}
          ''
      );

      # Stable path for wallpape
      home.file.".local/share/appearance/wallpaper" = lib.mkIf (wallpaper != null && !isDarwin) {
        source = config.lib.file.mkOutOfStoreSymlink (toString wallpaper);
      };

      home.activation.appearanceWallpaper = lib.hm.dag.entryAfter [ "appearanceMatugen" ] (
        if wallpaper == null then
          "exit 0"
        else if isDarwin then
          ''
            run ${pkgs.writeShellScript "set-darwin-wallpaper" ''
              set -euo pipefail
              export PATH="/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"
              /usr/bin/osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"${wallpaper}\""
            ''}
          ''
        else
          let
            wallpaperPath = toString wallpaper;
            gsettings = lib.getExe' pkgs.glib "gsettings";
            kwriteconfig6 = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
            plasmaWallpaper = lib.getExe' pkgs.kdePackages.plasma-workspace "plasma-apply-wallpaperimage";
          in
          ''
            run ${pkgs.writeShellScript "set-linux-wallpaper" ''
              set -euo pipefail
              wallpaper=${lib.escapeShellArg wallpaperPath}
              uri="file://$wallpaper"
              if [ ! -f "$wallpaper" ]; then
                echo "appearance: wallpaper not found: $wallpaper" >&2
                exit 1
              fi

              ${gsettings} set org.gnome.desktop.background picture-uri "$uri"
              ${gsettings} set org.gnome.desktop.background picture-uri-dark "$uri"
              ${gsettings} set org.gnome.desktop.screensaver picture-uri "$uri"

              ${kwriteconfig6} --file kscreenlockerrc \
                --group Greeter --group Wallpaper --group org.kde.image --group General \
                --key Image "$wallpaper"
              ${kwriteconfig6} --file kscreenlockerrc \
                --group Greeter --group Wallpaper --group org.kde.image --group General \
                --key PreviewImage "$wallpaper"
              # No-op outside an active Plasma session.
              ${plasmaWallpaper} "$wallpaper" >/dev/null 2>&1 || true
            ''}
          ''
      );

      # Qt apps on Plasma pick the icon theme from kdeglobals (GTK uses gtk.iconTheme above).
      home.activation.appearanceQtIcons = lib.mkIf (!isDarwin) (
        lib.hm.dag.entryAfter [ "appearanceMatugen" ] ''
          run ${kwriteconfig6} --file kdeglobals --group Icons --key Theme ${lib.escapeShellArg iconThemeName}
        ''
      );

      gtk = lib.mkIf (!isDarwin) {
        enable = true;
        colorScheme = colorScheme;
        theme = {
          name = gtkThemeName;
          package = pkgs.adw-gtk3;
        };
        iconTheme = {
          name = iconThemeName;
          package = pkgs.papirus-icon-theme;
        };
        # libadwaita ignores gtk-theme-name; colors come from gtk.css / colors.css
        gtk4.theme = null;
        gtk3.extraCss = lib.mkIf config.appearance.matugen.enable ''
          @import 'colors.css';
        '';
        gtk4.extraCss = lib.mkIf config.appearance.matugen.enable ''
          @import 'colors.css';
        '';
      };

      # What GNOME Tweaks reads. https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
      dconf.settings = lib.mkIf (!isDarwin) (
        {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-${colorScheme}";
            gtk-theme = gtkThemeName;
            icon-theme = iconThemeName;
          };
        }
        // lib.optionalAttrs (wallpaper != null) {
          "org/gnome/desktop/background" = {
            picture-uri = "file://${toString wallpaper}";
            picture-uri-dark = "file://${toString wallpaper}";
          };
          "org/gnome/desktop/screensaver" = {
            picture-uri = "file://${toString wallpaper}";
          };
        }
      );
    };
}
