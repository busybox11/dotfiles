# Public Zen config plus overlays. Overlay shape is `programs.zen-browser`.
# Nested attrs merge (pins, spaces, settings). List options concatenate
# (mods, extensions.packages); use lib.mkForce to replace a list.
#
# Later entries win on scalar conflicts:
#   public < local.zen < local.hosts.<name>.zen
#         < secrets.zen < secrets.hosts.<name>.zen
#
# Locked git-crypt: secret overlays are skipped, public config still applies.
{
  zen-browser,
  pkgs,
  lib,
  flakeHost,
  local,
  ...
}:
let
  secretsAttempt = builtins.tryEval (import ../../../../secrets/secrets.nix);
  secrets = if secretsAttempt.success then secretsAttempt.value else { };

  hostLocal = (local.hosts or { }).${flakeHost} or { };
  hostSecrets = (secrets.hosts or { }).${flakeHost} or { };
in
{
  imports = [
    zen-browser.homeModules.twilight
  ];

  programs.zen-browser = lib.mkMerge [
    {
      enable = true;
      setAsDefaultBrowser = true;

      policies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
      };

      profiles.default = import ./profile.nix { inherit pkgs; };
    }
    {
      profiles.default = {
        pins = import ./pins.nix;
        spaces = import ./spaces.nix;
      };
    }
    (local.zen or { })
    (hostLocal.zen or { })
    (secrets.zen or { })
    (hostSecrets.zen or { })
  ];
}
