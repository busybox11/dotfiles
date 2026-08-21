# Shared Chromium enterprise policies (Helium + Chrome).
# Helium: CWS update host is skipped unless the extension proxy is used.
# Chrome: official CWS Omaha URL. Also force-install uBlock (Helium ships it).
let
  heliumUpdateUrl = "https://services.helium.imput.net/ext/";
  chromeUpdateUrl = "https://clients2.google.com/service/update2/crx";
  ublockOriginId = "cjpalhdlnbpafiamejdnhcphjbkeiagm";

  extensionIds = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    "hlepfoohegkhhmjieoechaddaejaokhf" # Refined GitHub
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
    "hhinaapppaileiechjoiifaancjggfjm" # Web Scrobbler
    "fmkadmapgofadopljbjfkapdkoienihi" # React Developer Tools
    "clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
    "bggfcpfjbdkhfhfmkjpbhnkhnpjjeomc" # Material Icons for GitHub
    "dhdgffkkebhmkfjojejmpbldmpobfkfo" # Tampermonkey
  ];

  mkForceInstalled = updateUrl: {
    installation_mode = "force_installed";
    override_update_url = true;
    update_url = updateUrl;
  };

  mkPolicies =
    updateUrl: extraIds:
    let
      ids = extensionIds ++ extraIds;
      forceInstalled = mkForceInstalled updateUrl;
    in
    shared
    // {
      ExtensionInstallForcelist = map (id: "${id};${updateUrl}") ids;
      ExtensionSettings = builtins.listToAttrs (
        map (id: {
          name = id;
          value = forceInstalled;
        }) ids
      );
    };

  shared = {
    MetricsReportingEnabled = false;
    CloudReportingEnabled = false;
    UrlKeyedAnonymizedDataCollectionEnabled = false;
    UserFeedbackAllowed = false;
    ChromePromotionsEnabled = false;
    WelcomePageOnOSUpgradeEnabled = false;
    DefaultBrowserSettingEnabled = false;

    SearchSuggestEnabled = true;

    DefaultSearchProviderEnabled = true;
    DefaultSearchProviderName = "Kagi";
    DefaultSearchProviderKeyword = "@kg";
    DefaultSearchProviderSearchURL = "https://kagi.com/search?q={searchTerms}";
    DefaultSearchProviderSuggestURL = "https://kagi.com/api/autosuggest?q={searchTerms}";
    DefaultSearchProviderIconURL = "https://assets.kagi.com/v2/favicon-32x32.png";
  };
in
{
  inherit
    chromeUpdateUrl
    extensionIds
    heliumUpdateUrl
    shared
    ublockOriginId
    ;

  heliumPolicies = mkPolicies heliumUpdateUrl [ ];
  chromePolicies = mkPolicies chromeUpdateUrl [ ublockOriginId ];
}
