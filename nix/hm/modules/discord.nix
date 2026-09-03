{ pkgs, lib, ... }:
let
  inherit (import ../chromium-features.nix) wrap;
  equibopPatched = pkgs.equibop.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace src/main/mainWindow.ts --replace-fail 'backgroundThrottling: false' 'backgroundThrottling: false,
            additionalArguments: ["--scroll-bounce"]'
      '';
  });
in
{
  programs.equibop.enable = true;
  programs.equibop.package = wrap pkgs equibopPatched;
}