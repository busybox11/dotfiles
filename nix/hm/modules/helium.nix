{
  config,
  lib,
  pkgs,
  helium-browser,
  ...
}:
let
  inherit (import ../chromium-features.nix) flag;
  inherit (import ../../common/chromium-policies.nix)
    extensionIds
    heliumPolicies
    heliumUpdateUrl
    ;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
  imports = [ helium-browser.homeModules.default ];

  programs.helium = lib.mkIf isLinux {
    enable = true;
    package = pkgs.helium;
    flags = [ flag ];
    policies = heliumPolicies;
  };

  xdg.configFile = lib.mkIf isLinux (
    lib.listToAttrs (
      map (id: {
        name = "net.imput.helium/External Extensions/${id}.json";
        value.text = builtins.toJSON { external_update_url = heliumUpdateUrl; };
      }) extensionIds
    )
  );

  home.packages = lib.mkIf isLinux [
    (pkgs.writeShellScriptBin "helium-browser" ''
      exec ${
        lib.getExe (config.programs.helium.package.override { inherit (config.programs.helium) flags; })
      } "$@"
    '')
  ];
}
