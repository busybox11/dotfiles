let
  inherit (import ../../common/chromium-policies.nix) heliumPolicies chromePolicies;
  heliumJson = builtins.toJSON heliumPolicies;
  chromeJson = builtins.toJSON chromePolicies;
in
{
  environment.etc = {
    "chromium/policies/managed/helium.json".text = heliumJson;
    "helium/policies/managed/helium.json".text = heliumJson;
    "opt/chrome/policies/managed/chromium.json".text = chromeJson;
  };
}
