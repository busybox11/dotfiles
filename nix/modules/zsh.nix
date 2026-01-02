{ pkgs, dotfilesPath, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      cdot = "cd ${dotfilesPath}";
      hmdot-upd = "home-manager switch --flake ${dotfilesPath}#$USER";
    };
  };
}
