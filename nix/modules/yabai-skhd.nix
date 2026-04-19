# Loaded only via profiles/darwin.nix
# Config paths are flake-relative (../../config/...) so HM copies into the store;
# use `onChange` to restart daemons after `home-manager switch`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  logDir = "${config.home.homeDirectory}/Library/Logs";

  # skhd has no nix options here; we generate ~/.config/skhd/skhdrc.
  mkActivateApp =
    app:
    pkgs.writeShellScript "activate-app-${lib.replaceStrings [ " " ] [ "-" ] app}" ''
      exec osascript -e ${lib.escapeShellArg "tell application \"${app}\" to activate"}
    '';

  activateBindings = [
    {
      key = "cmd + ctrl - z";
      app = "Twilight";
    }
    {
      key = "cmd + ctrl - d";
      app = "Equibop";
    }
    {
      key = "cmd + ctrl - c";
      app = "Cursor";
    }
    {
      key = "cmd + ctrl - s";
      app = "Spotify";
    }
  ];

  ghosttyLauncher = "${config.xdg.configHome}/yabai/scripts/launchers/ghostty.applescript";
  skhdrcText =
    lib.concatStringsSep "\n" (
      [ "cmd - return : osascript ${lib.escapeShellArg ghosttyLauncher}" ]
      ++ map (b: "${b.key} : ${mkActivateApp b.app}") activateBindings
    )
    + "\n";

  envPath = lib.concatStringsSep ":" [
    (lib.makeBinPath [
      pkgs.yabai
      pkgs.skhd
    ])
    "${config.home.profileDirectory}/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
  agentEnv = {
    HOME = config.home.homeDirectory;
    XDG_CONFIG_HOME = config.xdg.configHome;
    PATH = envPath;
  };
in
{
  xdg.enable = true;

  home.packages = [
    pkgs.yabai
    pkgs.skhd
  ];

  xdg.configFile = {
    "yabai/yabairc" = {
      source = ../../config/yabai/yabairc;
      executable = true;
      onChange = ''
        /bin/launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.yabai" || true
      '';
    };
    "yabai/scripts/launchers/ghostty.applescript" = {
      source = ../../config/yabai/scripts/launchers/ghostty.applescript;
    };
    "skhd/skhdrc" = {
      text = skhdrcText;
      onChange = ''
        /bin/launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.skhd" || true
      '';
    };
  };

  launchd.agents.yabai = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.yabai}/bin/yabai" ];
      RunAtLoad = true;
      KeepAlive = true;
      LimitLoadToSessionType = "Aqua";
      EnvironmentVariables = agentEnv;
      StandardOutPath = "${logDir}/yabai.out.log";
      StandardErrorPath = "${logDir}/yabai.err.log";
    };
  };

  launchd.agents.skhd = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.skhd}/bin/skhd" ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 2;
      LimitLoadToSessionType = "Aqua";
      EnvironmentVariables = agentEnv;
      StandardOutPath = "${logDir}/skhd.out.log";
      StandardErrorPath = "${logDir}/skhd.err.log";
    };
  };
}
