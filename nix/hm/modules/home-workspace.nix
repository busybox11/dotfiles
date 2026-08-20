{ lib, pkgs, config, ... }:
let
  extraDirs = [
    "dev"
    "build"
    "tests"
    "contrib"
  ];
  toBookmark = path: "file://${path}";
in
lib.mkMerge [
  (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    xdg.userDirs.enable = true;
    xdg.userDirs.createDirectories = true;
    xdg.userDirs.setSessionVariables = true;
    gtk.gtk3.bookmarks =
      map toBookmark (
        lib.filter (p: p != null) [
          config.xdg.userDirs.documents
          config.xdg.userDirs.download
          config.xdg.userDirs.music
          config.xdg.userDirs.pictures
          config.xdg.userDirs.videos
        ]
      )
      ++ map (d: toBookmark "${config.home.homeDirectory}/${d}") extraDirs;
  })
  {
    home.file = lib.listToAttrs (map (d: lib.nameValuePair "${d}/.keep" { text = ""; }) extraDirs);
  }
]
