{
  pkgs,
  lib,
  flakeHost,
  ...
}:
let
  vscodeConfig = import ./vscode-config.nix { inherit pkgs flakeHost; };
  cursor = pkgs.code-cursor;
in
{
  programs.cursor = {
    enable = true;
    # https://forum.cursor.com/t/cursors-sandbox-unable-to-run-any-command-missing-zsh-mount-in-sandbox/159727/5
    package = pkgs.symlinkJoin {
      inherit (cursor) name pname version;
      paths = [ cursor ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm -f $out/bin/${cursor.meta.mainProgram}
        makeWrapper ${lib.getExe cursor} $out/bin/${cursor.meta.mainProgram} \
          --set SHELL ${lib.getExe pkgs.zsh}
      '';
      meta = cursor.meta;
    };

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}
