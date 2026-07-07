{
  config,
  lib,
  pkgs,
  dotfilesPath,
  flakeHost,
  ...
}:

{
  home.packages = with pkgs; [
    zsh-powerlevel10k
    zoxide
    eza
  ];

  programs.zsh = {
    # Lock legacy dotfile location until home.stateVersion >= 26.05 (HM warning).
    dotDir = config.home.homeDirectory;

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
      # path:… so gitignored nix/darwin-local.nix is visible (git+file: flakes omit it)
      hmdot-upd = "home-manager switch --flake path:${dotfilesPath}#${flakeHost}";

      n = "nvim";
      z = "nocorrect z";
      dmenu = "vicinae dmenu";
    };

    sessionVariables = {
      ARCHFLAGS = "-arch $(uname -m)"; # host-specific config todo

      EDITOR = "nvim"; # maybe set in nvim nix module later on / handle ssh sessions

      COMPLETION_WAITING_DOTS = "true";
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 1 ''
        if [[ -n "$TERM" ]] && command -v tput &>/dev/null; then
          export SUDO_PROMPT="$(tput bel)$(tput setab 1 setaf 7 bold)[sudo]$(tput sgr0) $(tput setaf 6)password for$(tput sgr0) $(tput setaf 5)%p$(tput sgr0): "
        else
          export SUDO_PROMPT="[sudo] password for %p: "
        fi
      '')
      (lib.mkOrder 10 ''
        # lightweight prompt for coding agents
        _dotfiles_is_ai_agent_shell() {
          [[ -n "$AI_AGENT" || -n "$AGENT" ]] && return 0

          [[ -n "$CURSOR_AGENT" || -n "$CURSOR_SANDBOX" ]] && return 0
          
          [[ -n "$OPENCODE" || -n "$OPENCODE_PID" ]] && return 0

          [[ -n "$CLAUDECODE" || -n "$CLAUDE_CODE_CHILD_SESSION" ]] && return 0

          [[ -n "$CODEX_THREAD_ID" || -n "$CODEX_SANDBOX" || -n "$CODEX_CI" ]] && return 0

          [[ -n "$GEMINI_CLI" || -n "$AUGMENT_AGENT" || -n "$CLINE_ACTIVE" ]] && return 0
          [[ -n "$ROO_ACTIVE" || -n "$ANTIGRAVITY_AGENT" || -n "$AMP_CURRENT_THREAD_ID" ]] && return 0
          [[ -n "$COPILOT_AGENT_SESSION_ID" || -n "$CRUSH" || -n "$GOOSE_TERMINAL" ]] && return 0

          return 1
        }

        typeset -g _DOTFILES_AI_AGENT_SHELL=0
        _dotfiles_is_ai_agent_shell && typeset -g _DOTFILES_AI_AGENT_SHELL=1
      '')
      (lib.mkOrder 50 ''
        if (( ! _DOTFILES_AI_AGENT_SHELL )) && [[ -o interactive ]] && ! setopt monitor 2>/dev/null; then
          # gitstatus needs job control; without it init fails and leaves $?=1 (red prompt).
          typeset -g _p9k_no_gitstatus=1
          typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=1
          typeset -g POWERLEVEL9K_VCS_BACKENDS=()
          # Stale p10k-dump can still call gitstatus_start from a previous config.
          rm -f "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-dump-''${(%):-%n}.zsh" \
                "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-dump-''${(%):-%n}.zsh.zwc" \
                "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" \
                "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh.zwc" 2>/dev/null
        fi
      '')
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
        if (( _DOTFILES_AI_AGENT_SHELL )); then
          PROMPT='%n@%m %1~ %# '
        else
          # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
          # Initialization code that may require console input (password prompts, [y/n]
          # confirmations, etc.) must go above this block; everything else may go below.
          if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
            source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          fi

          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source ${../../../shell/p10k.zsh}
        fi
      '')
      (lib.mkBefore ''
        hmu() {
          cd ${dotfilesPath} &&
          nix flake update --commit-lock-file &&
          home-manager switch --flake path:${dotfilesPath}#${flakeHost} &&
          cd -
        }
      '')
      (lib.mkOrder 1500 ''
        export PATH="$PATH:$HOME/.local/bin"
        
        # bun
        export PATH="$HOME/.bun/bin:$HOME/.cache/.bun/bin:$PATH"

        # go
        export PATH="$PATH:$HOME/go/bin"

        # rust
        export PATH="$PATH:$HOME/.cargo/bin"

        # kitty
        (( ! _DOTFILES_AI_AGENT_SHELL )) && typeset -g POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
        [ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
      '')
      (lib.mkOrder 2000 ''
        if (( ! _DOTFILES_AI_AGENT_SHELL )); then
          # Clear spurious non-zero status when gitstatus failed during p10k init.
          if (( ! ''${+_GITSTATUS_STATE_POWERLEVEL9K} || _GITSTATUS_STATE_POWERLEVEL9K != 2 )); then
            true
          fi
        fi
      '')
    ];
  };
}
