{
  zen-browser,
  pkgs,
  nur,
  ...
}:
{
  imports = [
    zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
    };

    profiles.default =
      let
        pins = {
          "Twitter" = {
            id = "a02fe8c7-dd4e-464f-84a5-3de78d11bd48";
            url = "https://x.com";
            position = 101;
            isEssential = true;
          };
          "SoundCloud" = {
            id = "27a02279-7de8-4a41-bf36-434286f9cbea";
            url = "https://soundcloud.com/you/library";
            position = 102;
            isEssential = true;
          };
          "Discord" = {
            id = "3b98b869-d64c-499f-a13b-fc11110934db";
            url = "https://discord.com/channels/@me";
            position = 103;
            isEssential = true;
          };
          "GitHub" = {
            id = "7d596c6c-5516-4b3e-9432-badc7df63651";
            url = "https://github.com";
            position = 104;
            isEssential = true;
          };
        };
      in
      {
        pinsForce = true;
        pinsForceAction = "demote";
        inherit pins;

        spaces = {
          "home" = {
            id = "cd1e4db5-6f9c-48ee-b94b-71207526046d";
            position = 1000;

            pins = {
              "BARRZZ" = {
                id = "8282d15e-88b2-4804-9bc9-573db6f9ebdb";
                url = "https://barrzz.fr";
                position = 201;
              };
            };

            theme = {
              opacity = 0.8;
              texture = 0.5;
            };
          };
          "work" = {
            id = "0a2df7a1-9c8e-4af3-aac4-808d5a7b15e0";
            position = 1001;

            theme = {
              opacity = 0.8;
              texture = 0.5;
            };
          };
        };

        search = {
          force = true;
          default = "Kagi";
          engines = {
            "Kagi" = {
              urls = [
                {
                  template = "https://kagi.com/search?q={searchTerms}";
                }
              ];
              icon = "https://assets.kagi.com/v2/favicon-32x32.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@kg" ];
            };
          };
        };

        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          refined-github
          darkreader
          istilldontcareaboutcookies
          web-scrobbler
          react-devtools
          stylus
          material-icons-for-github
          tampermonkey
        ];

        settings = {
          "zen.welcome-screen.seen" = true;
          "extensions.autoDisableScopes" = 0;
          "browser.aboutConfig.showWarning" = false;
          "browser.search.suggest.enabled" = true;
          "widget.dmabuf.force-enabled" = true;
          "font.name.monospace.x-western" = "Cascadia Code NF";
          "font.name.sans-serif.x-western" = "SF Pro Text";
          "font.name.serif.x-western" = "SF Pro Text";
          "zen.theme.content-element-separation" = 0;
          "zen.theme.gradient.show-custom-colors" = true;
          "zen.theme.use-system-colors" = true;
          "zen.urlbar.show-domain-only-in-sidebar" = false;

          "zen.widget.linux.transparency" = true;
          "browser.tabs.allow_transparent_browser" = true;
          "zen.view.experimental-no-window-controls" = true;
        };

        mods = [
          "81fcd6b3-f014-4796-988f-6c3cb3874db8"
          "f7c71d9a-bce2-420f-ae44-a64bd92975ab"
          "dbe05f83-b471-4278-a3f9-e5ed244b0d6c"
          "03a8e7ef-cf00-4f41-bf24-a90deeafc9db"
        ];

        userChrome = ''
          html {
            background: transparent !important;

            --lwt-accent-color-inactive: rgba(31, 30, 37, 0.75) !important;
          }

          browser {
            background:rgba(0, 0, 0, 0.35) !important;
          }
        '';
      };
  };
}
