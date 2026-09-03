{
  pkgs,
  lib,
  flakeHost,
  nestedInNixOS ? false,
  ...
}:
let
  vscodeConfig = import ./vscode-config.nix {
    inherit
      pkgs
      flakeHost
      nestedInNixOS
      ;
  };
  cursorBase =
    (pkgs.code-cursor.override { commandLineArgs = "--scroll-bounce"; }).overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          for f in $(find $out/lib/cursor/resources/app -type f -name "*.js" | xargs grep -l "additionalArguments" 2>/dev/null || true); do
            sed -i 's/additionalArguments:\s*\[/additionalArguments:["--scroll-bounce",/' "$f" || true
          done
          for f in $(find $out/lib/cursor/resources/app -type f -name "*.js" | xargs grep -l "inertialScroll" 2>/dev/null || true); do
            sed -i 's/"inertialScroll",!1/"inertialScroll",!0/g' "$f" || true
            sed -i 's/inertialScroll:typeof s\.inertialScroll<"u"?s\.inertialScroll:!1/inertialScroll:typeof s.inertialScroll<"u"?s.inertialScroll:!0/g' "$f" || true
            sed -i -E 's/&&![a-zA-Z0-9_]+\.isPhysicalMouseWheel\(\)//g' "$f" || true
          done
        '';
    });
in
{
  home.packages = vscodeConfig.sharedPackages;

  programs.cursor = {
    enable = true;
    # https://forum.cursor.com/t/cursors-sandbox-unable-to-run-any-command-missing-zsh-mount-in-sandbox/159727/5
    package = pkgs.symlinkJoin {
      inherit (cursorBase) name pname version;
      paths = [ cursorBase ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm -f $out/bin/${cursorBase.meta.mainProgram}
        makeWrapper ${lib.getExe cursorBase} $out/bin/${cursorBase.meta.mainProgram} \
          --set SHELL ${lib.getExe pkgs.zsh}
      '';
      meta = cursorBase.meta;
    };

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}
