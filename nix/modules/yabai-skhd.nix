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
      source = ../../config/skhd/skhdrc;
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
