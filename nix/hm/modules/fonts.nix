{
  lib,
  pkgs,
  fontsManagedByNixOS ? false,
  ...
}:
let
  fontPackages = import ../../fonts/packages.nix { inherit pkgs; };
  isLinux = pkgs.stdenv.hostPlatform.isLinux;

  sans = "SF Pro";
  mono = "Cascadia Code NF";
  size = 10;

  # Plasma still uses Qt's legacy weight scale in kdeglobals (50 = Normal/Regular).
  qtFont = family: "${family},${toString size},-1,5,50,0,0,0,0,0";

  kwriteconfig6 = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
  gsettings = lib.getExe' pkgs.glib "gsettings";
in
{
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";

    defaultFonts = {
      sansSerif = [ sans ];
      monospace = [ mono ];
    };

    configFile = {
      cascadia-features = {
        enable = true;
        priority = 80;
        text = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <description>Enable select opentype features for Cascadia Code</description>
            <match target="font">
              <test name="family" compare="eq" ignore-blanks="true">
                <string>Cascadia Code</string>
              </test>
              <edit name="fontfeatures" mode="append">
                <string>liga on</string>
                <string>ss01 on</string>
                <string>ss02 on</string>
                <string>ss19 on</string>
                <string>ss20 on</string>
                <string>tnum on</string>
                <string>zero on</string>
              </edit>
            </match>
            <match target="font">
              <test name="family" compare="eq" ignore-blanks="true">
                <string>Cascadia Code NF</string>
              </test>
              <edit name="fontfeatures" mode="append">
                <string>liga on</string>
                <string>ss01 on</string>
                <string>ss02 on</string>
                <string>ss19 on</string>
                <string>ss20 on</string>
                <string>tnum on</string>
                <string>zero on</string>
              </edit>
            </match>
            <match target="font">
              <test name="family" compare="eq" ignore-blanks="true">
                <string>Cascadia Code PL</string>
              </test>
              <edit name="fontfeatures" mode="append">
                <string>liga on</string>
                <string>ss01 on</string>
                <string>ss02 on</string>
                <string>ss19 on</string>
                <string>ss20 on</string>
                <string>tnum on</string>
                <string>zero on</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };
  };

  # GTK settings.ini (with gtk.enable from appearance.nix)
  gtk.font = lib.mkIf isLinux {
    name = sans;
    size = size;
  };

  # GNOME Tweaks / libadwaita
  dconf.settings = lib.mkIf isLinux {
    "org/gnome/desktop/interface" = {
      font-name = lib.mkForce "${sans} ${toString size}";
      document-font-name = lib.mkForce "${sans} ${toString size}";
      monospace-font-name = lib.mkForce "${mono} ${toString size}";
      font-antialiasing = "rgba";
      font-hinting = "slight";
    };
  };

  # Plasma fonts live in kdeglobals; also push monospace to gsettings (Tweaks reads that).
  home.activation.plasmaFonts = lib.mkIf isLinux (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${kwriteconfig6} --file kdeglobals --group General --key font ${lib.escapeShellArg (qtFont sans)}
      run ${kwriteconfig6} --file kdeglobals --group General --key menuFont ${lib.escapeShellArg (qtFont sans)}
      run ${kwriteconfig6} --file kdeglobals --group General --key toolBarFont ${lib.escapeShellArg (qtFont sans)}
      run ${kwriteconfig6} --file kdeglobals --group General --key smallestReadableFont ${lib.escapeShellArg (qtFont sans)}
      run ${kwriteconfig6} --file kdeglobals --group General --key activeFont ${lib.escapeShellArg (qtFont sans)}
      run ${kwriteconfig6} --file kdeglobals --group General --key fixed ${lib.escapeShellArg (qtFont mono)}
      run ${gsettings} set org.gnome.desktop.interface font-name ${lib.escapeShellArg "${sans} ${toString size}"}
      run ${gsettings} set org.gnome.desktop.interface document-font-name ${lib.escapeShellArg "${sans} ${toString size}"}
      run ${gsettings} set org.gnome.desktop.interface monospace-font-name ${lib.escapeShellArg "${mono} ${toString size}"}
    ''
  );

  home.packages = lib.mkIf (!fontsManagedByNixOS) fontPackages;
}
