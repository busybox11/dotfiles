{ zen-browser, pkgs, nur, ... }:
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
    
    profiles.default = {
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
        i-dont-care-about-cookies
        web-scrobbler
        react-devtools
        stylus
        material-icons-for-github
        tampermonkey
      ];

      settings = {
        "browser.aboutConfig.showWarning" = false;
        "widget.dmabuf.force-enabled" = true;
        "font.name.monospace.x-western" = "Cascadia Code NF";
        "font.name.sans-serif.x-western" = "SF Pro Text";
        "font.name.serif.x-western" = "SF Pro Text";
        "zen.theme.content-element-separation" = 0;
        "zen.theme.gradient.show-custom-colors" = true;
        "zen.theme.use-system-colors" = true;
        "zen.urlbar.show-domain-only-in-sidebar" = false;
      };

      mods = [
        "81fcd6b3-f014-4796-988f-6c3cb3874db8"
        "f7c71d9a-bce2-420f-ae44-a64bd92975ab"
        "dbe05f83-b471-4278-a3f9-e5ed244b0d6c"
        "03a8e7ef-cf00-4f41-bf24-a90deeafc9db"
      ];
    };
  };
}
