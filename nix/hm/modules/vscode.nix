{
  pkgs,
  flakeHost,
  nestedInNixOS ? false,
  vscode-server,
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
in
{
  # Import the module directly using the path to avoid using the flake's `homeModules.default` if it triggers recursion
  imports = [ "${vscode-server}/modules/vscode-server/home.nix" ];

  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_24;
    installPath = [
      "$HOME/.vscode-server"
      "$HOME/.code-server"
      "$HOME/.cursor-server"
    ];
  };

  home.packages = vscodeConfig.sharedPackages;

  programs.vscode = {
    enable = true;
    package =
      let
        vscodeWithBounce =
          (pkgs.vscode.override { commandLineArgs = "--scroll-bounce"; }).overrideAttrs (old: {
            postInstall =
              (old.postInstall or "")
              + ''
                for f in $(find $out/lib/vscode/resources/app -type f -name "*.js" | xargs grep -l "additionalArguments" 2>/dev/null || true); do
                  sed -i 's/additionalArguments:\s*\[/additionalArguments:["--scroll-bounce",/' "$f" || true
                done
                # enable inertialScroll by default for Monaco + all ScrollableElements and remove touchpad-vs-mouse misclassification
                for f in $(find $out/lib/vscode/resources/app -type f -name "*.js" | xargs grep -l "inertialScroll" 2>/dev/null || true); do
                  sed -i 's/"inertialScroll",!1/"inertialScroll",!0/g' "$f" || true
                  sed -i 's/inertialScroll:typeof s\.inertialScroll<"u"?s\.inertialScroll:!1/inertialScroll:typeof s.inertialScroll<"u"?s.inertialScroll:!0/g' "$f" || true
                  sed -i -E 's/&&![a-zA-Z0-9_]+\.isPhysicalMouseWheel\(\)//g' "$f" || true
                done
              '';
          });
      in
      vscodeWithBounce;

    profiles.default = {
      userSettings = vscodeConfig.sharedSettings;
      extensions = vscodeConfig.sharedExtensions;
    };
  };
}
