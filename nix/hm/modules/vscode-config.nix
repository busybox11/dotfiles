{
  pkgs,
  flakeHost ? null,
}:
let
  lib = pkgs.lib;
  nixosHosts = import ../../nixos/hosts/map.nix;

  # only enable hm / nixos options on dotfiles workspace
  nixdServerSettings =
    let
      flakeExpr = host: "(builtins.getFlake \"\${workspaceFolder}\").${host}";
      options = lib.optionalAttrs (flakeHost != null) {
        "home-manager" = {
          expr = "${flakeExpr "homeConfigurations.${flakeHost}"}.options";
        };
      }
      // lib.optionalAttrs (flakeHost != null && lib.hasAttr flakeHost nixosHosts) {
        nixos = {
          expr = "${flakeExpr "nixosConfigurations.${flakeHost}"}.options";
        };
      };
    in
    {
      formatting = {
        command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
      };
    }
    // lib.optionalAttrs (options != { }) {
      inherit options;
    };
in
let
  # Writes generated themes at runtime; installed as a mutable copy (see vscode-matugen-theme.nix).
  # Not yet in pkgs.vscode-marketplace; switch to buildVscodeMarketplaceExtension from there once indexed.
  matugenThemeExtension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "haikalllp";
      name = "matugen-theme";
      version = "1.0.2";
      sha256 = "1xnbv9wll67dnk749vv53af4d1ihvl9whkfssxx1irhkqdxzwbbz";
    };
  };

  # Cursor is on vscode 1.105.1, use compatible extension versions
  nixIdeExtension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "jnoortheen";
      name = "nix-ide";
      version = "0.5.7";
      sha256 = "1sjlnw92gr2xf6caxn3jn105l1rq3zcp4cwqhfqfj0r5yfx260pb";
    };
  };

  errorLensExtension = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "usernamehw";
      name = "errorlens";
      version = "3.26.0";
      sha256 = "0rmvzr5qsbq8zni9vwg4y6bh8l6s5hci974x676m57hi0pfj82d4";
    };
  };

  matugenThemeExtensionUniqueId = matugenThemeExtension.passthru.vscodeExtUniqueId;

  matugenThemeExtensionPath =
    "${matugenThemeExtension}/share/vscode/extensions/${matugenThemeExtension.passthru.vscodeExtUniqueId}";

  # pkgs.vscode-marketplace.* — versions track nix-vscode-extensions on flake update.
  vscodeMarketplaceExtensions = with pkgs.vscode-marketplace; [
    # haikalllp.matugen-theme  # once indexed, move matugenThemeExtension here and drop mutable install
  ];

  sharedExtensions = (with pkgs.vscode-extensions; [
    catppuccin.catppuccin-vsc-icons
    yoavbls.pretty-ts-errors
    gruntfuggly.todo-tree
    bradlc.vscode-tailwindcss
    esbenp.prettier-vscode
    biomejs.biome
    lokalise.i18n-ally
    dbaeumer.vscode-eslint
    aaron-bond.better-comments
    docker.docker
    ms-azuretools.vscode-containers
    ms-vscode-remote.remote-containers
  ]) ++ vscodeMarketplaceExtensions ++ [
    nixIdeExtension
    errorLensExtension
  ];

  sharedSettings = {
    "editor.fontFamily" = "'Cascadia Code NF', 'Google Sans Code NF', 'Droid Sans Mono', 'monospace', monospace";
    "editor.fontWeight" = "400";
    "editor.fontLigatures" = "'ss01', 'ss02', 'ss19', 'ss20', 'zero'";
    "editor.smoothScrolling" = true;
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.showFoldingControls" = "always";
    "editor.stickyScroll.enabled" = true;
    "editor.formatOnSave" = true;
    "editor.defaultFormatter" = "biomejs.biome";
    "editor.minimap.enabled" = true;
    "editor.minimap.renderCharacters" = false;
    "editor.bracketPairColorization.enabled" = true;
    "editor.bracketPairColorization.independentColorPoolPerBracketType" = true;
    "editor.tabSize" = 2;
    "editor.hover.delay" = 800;
    "editor.tabCompletion" = "on";
    "editor.suggest.localityBonus" = true;

    "workbench.activityBar.orientation" = "vertical";
    "workbench.iconTheme" = "catppuccin-mocha";
    "workbench.preferredDarkColorTheme" = "Matugen Bordered";
    "workbench.list.smoothScrolling" = true;
    "workbench.editor.closeEmptyGroups" = false;
    "workbench.editor.enablePreviewFromCodeNavigation" = true;
    "workbench.editor.enablePreviewFromQuickOpen" = true;
    "workbench.editor.enablePreview" = false;
    "workbench.editor.openPositioning" = "left";
    "workbench.experimental.share.enabled" = true;
    "workbench.editor.alwaysShowEditorActions" = true;
    "workbench.editor.highlightModifiedTabs" = true;
    "workbench.editor.autoLockGroups" = {
      "mainThreadWebview-markdown.preview" = true;
      "workbench.input.externalTerminal" = true;
    };
    "workbench.view.alwaysShowHeaderActions" = true;
    "workbench.agentsWindowButton.enabled" = false;
    "workbench.layoutControl.enabled" = false;

    "editor.codeActionsOnSave" = {
      "source.fixAll" = "explicit";
      "source.organizeImports" = "explicit";
    };

    "editor.tokenColorCustomizations" = {
      "comments" = {
        "fontStyle" = "italic";
      };
      "strings" = {
        "fontStyle" = "italic";
      };
    };

    "terminal.integrated.smoothScrolling" = true;
    "terminal.integrated.fontLigatures.enabled" = true;
    "terminal.integrated.fontFamily" = "'CaskaydiaCove NF', 'Cascadia Code NF', 'Google Sans Code NF', 'Droid Sans Mono', 'monospace', monospace";
    "terminal.external.linuxExec" = "kitty";
    "terminal.integrated.cursorBlinking" = true;
    "terminal.integrated.enableVisualBell" = true;
    "terminal.integrated.shellIntegration.environmentReporting" = true;
    "terminal.integrated.stickyScroll.enabled" = true;
    "terminal.integrated.suggest.enabled" = true;
    "terminal.integrated.defaultLocation" = "editor";

    "debug.console.fontFamily" = "'Cascadia Code NF', 'Google Sans Code NF', 'Droid Sans Mono', 'monospace', monospace";

    "scm.defaultViewMode" = "tree";
    "search.defaultViewMode" = "tree";
    "search.showLineNumbers" = true;
    "search.quickOpen.includeSymbols" = true;

    "git.terminalGitEditor" = true;
    "git.blame.editorDecoration.enabled" = true;
    "git.showCursorWorktrees" = true;
    "git.enableCommitSigning" = true;

    "window.dialogStyle" = "custom";
    "window.confirmBeforeClose" = "always";
    "window.customTitleBarVisibility" = "auto";
    "window.controlsStyle" = "native";
    "window.commandCenter" = false;
    "window.titleBarStyle" = "native";
    "window.menuBarVisibility" = "hidden";
    "window.autoDetectColorScheme" = true;

    "typescript.preferences.importModuleSpecifier" = "non-relative";
    "typescript.suggest.autoImports" = true;
    "typescript.tsserver.log" = "off";
    "javascript.preferences.importModuleSpecifier" = "non-relative";
    "javascript.suggest.autoImports" = true;

    "tsEssentialPlugins.patchOutline" = true;
    "tsEssentialPlugins.displayAdditionalInfoInCompletions" = true;
    "tsEssentialPlugins.enableFileDefinitions" = true;
    "tsEssentialPlugins.enableVueSupport" = true;

    "typescriptExplorer.typeTree.meta.typeArguments.includeInFunctions" = true;
    "typescriptExplorer.typeTree.readonly.enable" = true;
    "typescriptExplorer.errorMessages.showDialogue" = true;

    "remote.autoForwardPortsSource" = "hybrid";

    "update.releaseTrack" = "prerelease";
    "database-client.autoSync" = true;
    "makefile.configureOnOpen" = true;
    "json.schemaDownload.enable" = true;
    "diffEditor.ignoreTrimWhitespace" = false;
    "shellformat.useEditorConfig" = true;

    "todo-tree.highlights.customHighlight" = {
      "TODO" = {
        icon = "check";
        type = "whole-line";
        background = "#99500080";
        color = "orange";
      };
    };

    "cursor.composer.shouldChimeAfterChatFinishes" = true;
    "cursor.composer.shouldAllowCustomModes" = true;
    "cursor.composer.queueMessageDefaultBehavior" = "stop-and-send";
    "cursor.composer.usageSummaryDisplay" = "always";
    "cursor.composer.suggestNextPrompt" = true;
    "cursor.cpp.disabledLanguages" = [ "plaintext" ];
    "cursor.cpp.enablePartialAccepts" = true;
    "cursor.semanticSearch.includeCommitsWithFiles" = true;
    "cursor.terminal.usePreviewBox" = true;
    "cursor.general.glassShowWarningNotifications" = true;
    "cursor.general.emailPrivacyEnabled" = true;

    "containers.contexts.showInStatusBar" = true;

    "[dotenv]" = {
      "editor.formatOnSave" = false;
    };

    "[nix]" = {
      "editor.defaultFormatter" = "jnoortheen.nix-ide";
      "editor.formatOnSave" = true;
    };

    "nix.enableLanguageServer" = true;
    "nix.serverPath" = [ "${pkgs.nixd}/bin/nixd" ];
    "nix.serverSettings" = {
      nixd = nixdServerSettings;
    };
  };
in
  {
    inherit
      sharedExtensions
      sharedSettings
      matugenThemeExtension
      matugenThemeExtensionUniqueId
      matugenThemeExtensionPath
      ;
  }
