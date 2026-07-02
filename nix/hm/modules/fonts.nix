{ lib, pkgs, fontsManagedByNixOS ? false, ... }:
let
  fontPackages = import ../../fonts/packages.nix { inherit pkgs; };
in
{
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "slight";
    subpixelRendering = "rgb";

    defaultFonts = {
      sansSerif = [ "SF Pro" ];
      monospace = [ "Cascadia Code NF" ];
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

  home.packages = lib.mkIf (!fontsManagedByNixOS) fontPackages;
}
