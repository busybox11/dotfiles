{
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  elementary = pkgs.pantheon.elementary-icon-theme;
  version = elementary.version or "0.0.0";

  theme = pkgs.stdenv.mkDerivation {
    pname = "elementary-hyprcursor";
    inherit version;

    nativeBuildInputs = [
      pkgs.hyprcursor # hyprcursor-util
      pkgs.xcur2png # hyprcursor-util --extract shells out to this
    ];

    dontUnpack = true;

    buildPhase = ''
      runHook preBuild

      hyprcursor-util --extract ${elementary}/share/icons/elementary \
        --output . --resize bilinear

      sed -i 's/^name = .*/name = hyprelementary/' \
        extracted_elementary/manifest.hl

      mkdir -p compiled
      hyprcursor-util --create extracted_elementary --output compiled

      mkdir -p $out/share/icons/hyprelementary
      cp -r compiled/theme_hyprelementary/. $out/share/icons/hyprelementary/

      runHook postBuild
    '';
  };
in
{
  home.file.".local/share/icons/hyprelementary" = lib.mkIf (!isDarwin) {
    source = "${theme}/share/icons/hyprelementary";
  };
}
