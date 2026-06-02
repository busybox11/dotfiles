username:
{ config, lib, ... }:
let
  cfg = config.services.musicStack;
in
{
  options.services.musicStack = {
    enable = lib.mkEnableOption "music library stack (Lidarr, Navidrome, and optional download clients)";

    libraryPath = lib.mkOption {
      type = lib.types.str;
      default = "/srv/music";
      description = "Root music library path (Lidarr root folder).";
    };

    downloadPath = lib.mkOption {
      type = lib.types.str;
      default = "/srv/music/downloads";
      description = "Incomplete and completed torrent downloads (qBittorrent save path).";
    };

    mediaGroup = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "Group with read/write access to the library and downloads.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = ''
        Bind address for Lidarr, Navidrome, Prowlarr, and qBittorrent web UIs.
        Use Tailscale or SSH tunnels; firewall stays closed by default.
      '';
    };

    torrent = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run Prowlarr and qBittorrent for torrent indexers (e.g. via Jackett/Prowlarr).";
      };
    };

    soulseek = {
      enable = lib.mkEnableOption "slskd Soulseek client (separate from Lidarr)";

      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          Environment file with SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, and web UI credentials.
          Required when soulseek.enable is true.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.soulseek.enable || cfg.soulseek.environmentFile != null;
        message = "services.musicStack.soulseek.environmentFile must be set when soulseek.enable is true.";
      }
    ];

    users.groups.${cfg.mediaGroup} = { };

    users.users.${username} = {
      extraGroups = [ cfg.mediaGroup ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.libraryPath} 0775 ${username} ${cfg.mediaGroup} -"
      "d ${cfg.downloadPath} 0775 ${username} ${cfg.mediaGroup} -"
      "d ${cfg.downloadPath}/.incomplete 0775 ${username} ${cfg.mediaGroup} -"
    ];

    services.lidarr = {
      enable = true;
      group = cfg.mediaGroup;
      settings.server.bindaddress = cfg.listenAddress;
      settings.server.port = 8686;
    };

    systemd.services.lidarr.serviceConfig.SupplementaryGroups = [ cfg.mediaGroup ];

    services.navidrome = {
      enable = true;
      group = cfg.mediaGroup;
      settings = {
        Address = cfg.listenAddress;
        Port = 4533;
        MusicFolder = cfg.libraryPath;
      };
    };

    services.prowlarr = lib.mkIf cfg.torrent.enable {
      enable = true;
      settings.server.bindaddress = cfg.listenAddress;
      settings.server.port = 9696;
    };

    services.qbittorrent = lib.mkIf cfg.torrent.enable {
      enable = true;
      group = cfg.mediaGroup;
      webuiPort = 8080;
      serverConfig = {
        Downloads.SavePath = cfg.downloadPath;
        WebUI.Address = cfg.listenAddress;
        WebUI.Port = 8080;
      };
    };

    systemd.services.qbittorrent.serviceConfig.SupplementaryGroups = lib.mkIf cfg.torrent.enable [
      cfg.mediaGroup
    ];

    services.slskd = lib.mkIf cfg.soulseek.enable {
      enable = true;
      group = cfg.mediaGroup;
      environmentFile = cfg.soulseek.environmentFile;
      settings = {
        directories.downloads = cfg.downloadPath;
        directories.incomplete = "${cfg.downloadPath}/.incomplete";
        shares.directories = [ cfg.libraryPath ];
        web.port = 5030;
      };
    };

    systemd.services.slskd.serviceConfig.SupplementaryGroups = lib.mkIf cfg.soulseek.enable [
      cfg.mediaGroup
    ];
  };
}
