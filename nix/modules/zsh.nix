{ pkgs, dotfilesPath, ... }:

{
  home.packages = with pkgs; [ zsh-powerlevel10k ];
  home.file.".p10k.zsh".text = builtins.readFile ../../shell/p10k.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    history = {
      extended = true;
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "git-extras"
        "fzf"
        "zoxide"
        "eza"
        "colorize"
        "extract"
        "docker"
        "docker-compose"
        "systemd"
        "tailscale"
        "nvm"
        "command-not-found"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initExtra = ''
      source ~/.p10k.zsh
    '';

    shellAliases = {
      cdot = "cd ${dotfilesPath}";
      hmdot-upd = "home-manager switch --flake ${dotfilesPath}#$USER";
    };
  };
}
