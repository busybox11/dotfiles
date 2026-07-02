{ zen-browser, pkgs, nur, ... }:
{
  imports = [
    zen-browser.homeModules.twilight
  ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DefaultSearchEngine = "Kagi";
    };
    profiles.default = {
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
    };
  };
}
