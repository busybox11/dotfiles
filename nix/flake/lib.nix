{
  inputs,
  hosts,
  local,
}:
let
  inherit (inputs)
    nixpkgs
    home-manager
    self
    zen-browser
    helium-browser
    apple-fonts
    nix-vscode-extensions
    vscode-server
    kwin-effects-better-blur-dx
    twintail-nix
    nur
    ;
  lib = nixpkgs.lib;

  overlays = [
    apple-fonts.overlays.default
    nur.overlays.default
    nix-vscode-extensions.overlays.default
    helium-browser.overlays.default
    (import ../overlays/dlib.nix)
    (import ../overlays/opencode2.nix inputs)
  ];

  pkgsFor =
    system:
    import nixpkgs {
      inherit system;
      inherit overlays;
    };

  hmModulesFor =
    machine:
    (lib.optional ((machine.hmProfile or "common") == "graphical") ../hm/profiles/graphical.nix)
    ++ (lib.optional ((machine.hmProfile or "common") == "darwin") ../hm/profiles/darwin.nix)
    ++ (lib.optional (machine.features.work or false) ../hm/modules/work.nix)
    ++ (lib.optional (machine.features.twintail or false) ../hm/modules/twintail.nix);
  # ++ (lib.optional (machine.features.hypridle or false) ../hm/modules/hypridle.nix);

  mkHome =
    {
      system,
      username,
      homeDirectory,
      dotfilesPath,
      flakeHost,
      extraModules ? [ ],
      hmProfile ? "common",
      features ? { },
      nestedInNixOS ? false,
      ...
    }@machine:
    home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;

      modules = [
        ../hm/default.nix
        ../hm/from-flake-local.nix
      ]
      ++ hmModulesFor machine
      ++ extraModules;

      extraSpecialArgs = {
        inherit
          self
          username
          homeDirectory
          dotfilesPath
          flakeHost
          local
          zen-browser
          helium-browser
          vscode-server
          twintail-nix
          nestedInNixOS
          ;
      };
    };

  mkNixOS =
    hostName:
    let
      machine = hosts.${hostName} // {
        inherit hostName;
      };
    in
    nixpkgs.lib.nixosSystem {
      system = machine.system;
      specialArgs = {
        inherit
          self
          local
          zen-browser
          helium-browser
          vscode-server
          kwin-effects-better-blur-dx
          twintail-nix
          machine
          ;
      };
      modules = [
        home-manager.nixosModules.home-manager
        (import ../nixos/profiles/personal-machine.nix {
          inherit (machine)
            hostName
            username
            dotfilesPath
            homeDirectory
            ;
          hmExtraModules = hmModulesFor machine;
          monitoring = machine.features.monitoring or true;
        })
        ../nixos/hosts/${hostName}/configuration.nix
        { nixpkgs.overlays = overlays; }
      ];
    };

  mkDarwinHome =
    let
      localPath = ../hm/darwin-local.nix;
    in
    if builtins.pathExists localPath then
      let
        darwinLocal = import localPath;
      in
      lib.optionalAttrs (lib.hasSuffix "-darwin" darwinLocal.system) {
        darwin = mkHome {
          system = darwinLocal.system;
          username = darwinLocal.username;
          homeDirectory = darwinLocal.homeDirectory;
          dotfilesPath = darwinLocal.dotfilesPath;
          flakeHost = "darwin";
          hmProfile = "darwin";
          features = {
            work = true;
          };
          nestedInNixOS = false;
        };
      }
    else
      { };
in
{
  inherit
    lib
    mkHome
    mkNixOS
    mkDarwinHome
    ;
}
