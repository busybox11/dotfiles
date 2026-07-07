{ config, lib, pkgs, ... }:
let
  inherit (import ./vscode-config.nix { inherit pkgs; })
    matugenThemeExtensionUniqueId
    matugenThemeExtensionPath
    ;

  extensionDirs = lib.concatLists [
    (lib.optional (config.programs.vscode.enable or false) "${config.home.homeDirectory}/.vscode/extensions")
    (lib.optional (config.programs.cursor.enable or false) "${config.home.homeDirectory}/.cursor/extensions")
  ];

  activationAfter = [
    "writeBoundary"
  ]
  ++ lib.optional (config.programs.vscode.enable or false) "vscodeProfiles"
  ++ lib.optional (config.programs.cursor.enable or false) "cursorProfiles";

  installScript = pkgs.writeShellScript "install-matugen-vscode-theme" ''
    set -euo pipefail
    storePath=${lib.escapeShellArg matugenThemeExtensionPath}
    extId=${lib.escapeShellArg matugenThemeExtensionUniqueId}
    for dir in "$@"; do
      extDir="$dir/$extId"
      if [ -e "$extDir" ]; then
        chmod -R u+w "$extDir" 2>/dev/null || true
        rm -rf "$extDir"
      fi
      cp -a "$storePath" "$extDir"
      chmod -R u+w "$extDir"
      mkdir -p "$extDir/themes"
    done
  '';
in
lib.mkIf (extensionDirs != [ ]) {
  home.activation.installMatugenThemeExtension = lib.hm.dag.entryAfter activationAfter ''
    ${lib.getExe' installScript "install-matugen-vscode-theme"} ${lib.concatMapStringsSep " " lib.escapeShellArg extensionDirs}
  '';
}
