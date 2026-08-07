{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [ "root" "@wheel" ];
  };
}
