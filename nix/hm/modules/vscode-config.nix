{ pkgs }:
let
  sharedExtensions = with pkgs.vscode-extensions; [
    catppuccin.catppuccin-vsc-icons
    bbenoist.nix
    yoavbls.pretty-ts-errors
    usernamehw.errorlens
    gruntfuggly.todo-tree
    bradlc.vscode-tailwindcss
    esbenp.prettier-vscode
    lokalise.i18n-ally
    dbaeumer.vscode-eslint
    aaron-bond.better-comments
    docker.docker
    ms-azuretools.vscode-containers
    ms-vscode-remote.remote-containers
  ];

  sharedSettings = {
    "editor.fontFamily" = "'Cascadia Code NF', 'Cascadia Code', 'Droid Sans Mono', 'monospace', monospace";
    "editor.fontWeight" = "400";
    "editor.fontLigatures" = "'ss01', 'ss02', 'ss19', 'ss20', 'zero'";
    "editor.smoothScrolling" = true;
    "editor.inertialScroll" = true;
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.showFoldingControls" = "always";
    "editor.stickyScroll.enabled" = true;
    "editor.brackerPairColorization.enabled" = true;
    "editor.brackerPairColorization.independentColorPoolPerBracketType" = true;
    "editor.tabSize" = 2;
    "editor.hover.delay" = 800;

    "workbench.activityBar.orientation" = "vertical";
    "workbench.iconTheme" = "catppuccin-mocha";

    "editor.tokenColorCustomizations" = {
      "comments" = {
        "fontStyle" = "italic";
      };
      "strings" = {
        "fontStyle" = "italic";
      };
    };
  };
in
  { inherit sharedExtensions sharedSettings; }
