{ pkgs }:
{
  pinsForce = true;
  pinsForceAction = "demote";

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
}
