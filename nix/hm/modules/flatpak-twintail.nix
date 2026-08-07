{
  nix-flatpak,
  config,
  ...
}:
let
  # https://github.com/gmodena/nix-flatpak/issues/31
  flatpakShareDirs = [
    "/var/lib/flatpak/exports/share"
    "${config.xdg.dataHome}/flatpak/exports/share"
  ];
in
{
  imports = [ nix-flatpak.homeManagerModules.nix-flatpak ];

  xdg.systemDirs.data = flatpakShareDirs;

  home.sessionPath = [
    "/usr/bin"
    "/bin"
  ];

  xdg.configFile."environment.d/99-flatpak-glycin-path.conf".text = ''
    PATH=/usr/bin:/bin:$PATH
  '';

  services.flatpak = {
    packages = [
      "app.twintaillauncher.ttl"
    ];

    overrides = {
      global = {
        Context.filesystems = [ "/nix/store:ro" ];
      };

      "app.twintaillauncher.ttl" = {
        Context.filesystems = [
          "${config.home.homeDirectory}/games/genshin"
        ];
        Environment.GTK_USE_PORTAL = "0";
      };
    };
  };
}
