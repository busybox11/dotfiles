{ pkgs, config, dotfilesPath, ... }:
{
  # Symlink to the repo checkout so lazy.nvim can write lazy-lock.json (HM store paths are read-only).
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/nvim";

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withPython3 = true;
    withNodeJs = true;
    
    withRuby = false;

    sideloadInitLua = true;

    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil
      rust-analyzer
      gopls
      pyright
      typescript-language-server
      bash-language-server
      yaml-language-server
      vscode-langservers-extracted
      marksman
      taplo

      # Tools
      ripgrep
      fd
      fzf
      prettier
      eslint
      stylua
      beautysh
      shfmt
      black
      isort
      alejandra

      # nvim-treesitter complains about not having a compiler
      # i hate this
      # i should really use a nix-native neovim config
      gcc

      # Formatters/Linters
      nodejs
      python3
    ];
  };
}
