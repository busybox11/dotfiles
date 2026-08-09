{
  lib,
  pkgs,
  ...
}:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  kwriteconfig6 = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
  qdbus = lib.getExe' pkgs.kdePackages.qttools "qdbus";
  # Twilight desktop uses StartupWMClass=zen-twilight
  zenWindowClasses = "zen-twilight";
in
{
  # Enable Better Blur DX, kill stock blur, force-blur Zen chrome.
  # Keys: https://github.com/xarblu/kwin-effects-better-blur-dx (Effect-better-blur-dx)
  home.activation.plasmaBetterBlur = lib.mkIf isLinux (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${kwriteconfig6} --file kwinrc --group Plugins --key blurEnabled false
      run ${kwriteconfig6} --file kwinrc --group Plugins --key better_blur_dxEnabled true
      run ${kwriteconfig6} --file kwinrc --group Effect-better-blur-dx --key BlurMatching true
      run ${kwriteconfig6} --file kwinrc --group Effect-better-blur-dx --key BlurNonMatching false
      run ${kwriteconfig6} --file kwinrc --group Effect-better-blur-dx --key WindowClasses ${lib.escapeShellArg zenWindowClasses}
      # Pick up kwinrc when a Plasma session is already up (else no-op).
      run ${qdbus} org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
    ''
  );
}
