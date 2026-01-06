{
  description = "rain personal dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      mkHome =
        user: path:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            ./nix/home.nix
          ];
          extraSpecialArgs = {
            username = user;
            dotfilesPath = path;
          };
        };
    in
    {
      homeConfigurations = {
        rain = mkHome "rain" "/home/rain/dev/dotfiles";
        busybox = mkHome "busybox" "/home/busybox/dev/dotfiles";
      };
    };
}
