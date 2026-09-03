# Single host inventory. Flake outputs and personal-machine identity are
# derived from this. Host-specific hardware stays in nix/nixos/hosts/<name>/.
#
# nixos          -> nixosConfigurations.<name>
# home           -> standalone homeConfigurations.<name> (nested HM is automatic on nixos)
# hmProfile      -> extra HM modules: "graphical" | "common" | "darwin"
# deploy.ipv4    -> deploy-rs node; omit deploy for machines that are not a target
#                   (laptops may be on Tailscale, but that is not guaranteed)
{
  chaeri = {
    system = "x86_64-linux";
    username = "rain";
    homeDirectory = "/home/rain";
    dotfilesPath = "/home/rain/.dotfiles";
    nixos = true;
    home = false;
    hmProfile = "graphical";
    features = {
      work = true;
      twintail = true;
      hypridle = true;
    };
  };

  voidroid = {
    system = "x86_64-linux";
    username = "rain";
    homeDirectory = "/home/rain";
    dotfilesPath = "/home/rain/.dotfiles";
    nixos = true;
    home = true;
    hmProfile = "graphical";
    features = {
      work = true;
    };
  };

  bitcrusher = {
    system = "x86_64-linux";
    username = "rain";
    homeDirectory = "/home/rain";
    dotfilesPath = "/home/rain/.dotfiles";
    nixos = true;
    home = true;
    hmProfile = "graphical";
    features = {
      work = true;
    };
  };

  lovefield = {
    system = "x86_64-linux";
    username = "rain";
    homeDirectory = "/home/rain";
    dotfilesPath = "/home/rain/build/dotfiles";
    nixos = true;
    home = false;
    hmProfile = "common";
    features = {
      work = true;
    };
    deploy = {
      ipv4 = "192.168.1.20";
    };
  };

  # Arch-host migration VM. Not a deploy-rs target.
  devvm = {
    system = "x86_64-linux";
    username = "rain";
    homeDirectory = "/home/rain";
    dotfilesPath = "/home/rain/dev/dotfiles_nixos";
    nixos = true;
    home = false;
    hmProfile = "graphical";
    features = {
      work = false;
      monitoring = false; # VM: skip node exporter / vmagent
    };
  };

  realbox = {
    system = "x86_64-linux";
    username = "rain";
    homeDirectory = "/home/rain";
    dotfilesPath = "/home/rain/dev/dotfiles";
    nixos = false;
    home = true;
    hmProfile = "graphical";
    features = {
      work = true;
    };
  };

  powerbox = {
    system = "x86_64-linux";
    username = "busybox";
    homeDirectory = "/home/busybox";
    dotfilesPath = "/home/busybox/dev/dotfiles";
    nixos = false;
    home = true;
    hmProfile = "graphical";
    features = {
      work = false;
    };
  };
}
