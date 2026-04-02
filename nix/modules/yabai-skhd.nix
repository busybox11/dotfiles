# Loaded only via profiles/darwin.nix
{
  config,
  lib,
  pkgs,
  dotfilesPath,
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

  xdg.configFile."yabai".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/yabai";
  xdg.configFile."skhd".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/skhd";

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
