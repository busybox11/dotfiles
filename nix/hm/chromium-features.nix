rec {
  features = "ElasticOverscroll,TouchpadOverscrollHistoryNavigation";
  flag = "--enable-features=${features}";

  # session env is notably ignored by CEF (Spotify)
  wrap =
    pkgs: pkg:
    pkgs.symlinkJoin {
      inherit (pkg) name pname version;
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/${pkg.meta.mainProgram} \
          --add-flags ${pkgs.lib.escapeShellArg flag} \
          --set ELECTRON_ENABLE_FEATURES ${pkgs.lib.escapeShellArg features}
      '';
      meta = pkg.meta;
    };
}
