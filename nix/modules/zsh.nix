{
  lib,
  pkgs,
  dotfilesPath,
  ...
}:

{
  home.packages = with pkgs; [ zsh-powerlevel10k ];

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

    shellAliases = {
      cdot = "cd ${dotfilesPath}";
      hmdot-upd = "home-manager switch --flake ${dotfilesPath}#$USER";

      n = "nvim";
      z = "nocorrect z";
      dmenu = "vicinae dmenu";
    };

    sessionVariables = {
      ARCHFLAGS = "-arch $(uname -m)"; # host-specific config todo

      EDITOR = "nvim"; # maybe set in nvim nix module later on / handle ssh sessions

      SUDO_PROMPT = "$(tput bel)$(tput setab 1 setaf 7 bold)[sudo]$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput setaf 5)%p$(tput sgr0): ";
      COMPLETION_WAITING_DOTS = "true";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 100 ''
        # styles
        zstyle ':omz:plugins:eza' 'header' no
        zstyle ':omz:plugins:eza' 'dirs-first' yes
        zstyle ':omz:plugins:eza' 'git-status' yes
        zstyle ':omz:plugins:eza' 'icons' yes
        zstyle ':omz:plugins:eza' 'hyperlink' yes

        # nvm zsh plugin is Very Slow
        zstyle ':omz:plugins:nvm' lazy yes
      '')
      (lib.mkOrder 500 ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        # Initialization code that may require console input (password prompts, [y/n]
        # confirmations, etc.) must go above this block; everything else may go below.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ${../../shell/p10k.zsh}
      '')
      (lib.mkOrder 1500 ''
        # bun
        export PATH="$HOME/.bun/bin:$HOME/.cache/.bun/bin:$PATH"

        # go
        export PATH="$PATH:$HOME/go/bin"

        # rust
        export PATH="$PATH:$HOME/.cargo/bin"

        # kitty
        typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
        [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
      '')
    ];
  };
}
