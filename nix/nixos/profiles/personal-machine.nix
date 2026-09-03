# HM + primary user. flakeHost follows networking.hostName (= hostName).
{
  hostName,
  username,
  dotfilesPath,
  homeDirectory,
  hmExtraModules ? [ ],
  monitoring ? false,
}:
{
  self,
  local,
  pkgs,
  lib,
  zen-browser,
  helium-browser,
  vscode-server,
  twintail-nix,
  ...
}:
{
  imports = [
    ../modules/fonts.nix
    (import ../modules/superbird.nix username)
    (import ../modules/docker.nix username)
  ]
  ++ lib.optional monitoring ../modules/monitoring.nix;

  services.fwupd.enable = true;

  networking.hostName = hostName;

  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "i2c"
    ];
  };

  services.flatpak.enable = true;

  # mostly vscode remote ssh
  programs.nix-ld.enable = true;

  programs.nh = {
    enable = true;
    flake = "path:${dotfilesPath}";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  programs.steam.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "hmbak-${toString self.lastModified}";

  home-manager.extraSpecialArgs = {
    inherit
      local
      self
      username
      homeDirectory
      dotfilesPath
      zen-browser
      helium-browser
      vscode-server
      twintail-nix
      ;
    flakeHost = hostName;
    nestedInNixOS = true;
  };

  home-manager.users.${username} = {
    imports = [
      ../../hm/default.nix
      ../../hm/from-flake-local.nix
    ]
    ++ hmExtraModules;
    home.packages = [ pkgs.home-manager ];
  };
}
