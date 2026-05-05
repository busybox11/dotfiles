{ lib, pkgs, ... }:
let
  extraDirs = [
    "dev"
    "build"
    "tests"
    "contrib"
  ];
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    xdg.userDirs.enable = true;
    xdg.userDirs.createDirectories = true;
  })
  {
    home.file = lib.listToAttrs (
      map (d: lib.nameValuePair "${d}/.keep" { text = ""; }) extraDirs
    );
  }
]
