{ config, lib, pkgs, flakeHost, ... }:
{
  config = lib.mkIf (flakeHost == "chaeri") {
    services.easyeffects = {
      enable = true;
      # global preset disabled; per-route autoload below handles speaker-only
      preset = "";
      extraPresets = {
        "ROG G14" = {
          output = (builtins.fromJSON (builtins.readFile (pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/RaduTek/EasyEffects-Presets/main/Asus%20ROG%20Zephyrus%20G14.json";
            hash = "sha256-D6+f6PouxOtEJLeauXYsZ3YzP8iSFfxgjn1uM57f0Po=";
          }))).output;
        };
        "Advanced Auto Gain" = {
          output = (builtins.fromJSON (builtins.readFile (pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/JackHack96/EasyEffects-Presets/master/Advanced%20Auto%20Gain.json";
            hash = "sha256-AXzy04ORMeg39H7ojkRtuumT0HU0nKLkU1SKmmD9zzQ=";
          }))).output;
        };
        "Blank" = {
          output = {
            blocklist = [ ];
            plugins_order = [ ];
          };
        };
      };
    };

    # Speaker-only autoload: ROG G14 on analog-output-speaker, Blank on headphones
    # EasyEffects 8.x autoload dir is XDG_DATA_HOME/easyeffects/autoload/output
    # Filename = {node.name}:{route}.json, JSON has device fields (see wwmm/easyeffects#1051)
    xdg.dataFile."easyeffects/autoload/output/alsa_output.pci-0000_65_00.6.analog-stereo:analog-output-speaker.json".text = builtins.toJSON {
      device = "alsa_output.pci-0000_65_00.6.analog-stereo";
      device-description = "Ryzen HD Audio Controller Analog Stereo";
      device-profile = "analog-output-speaker";
      preset-name = "ROG G14";
    };
    xdg.dataFile."easyeffects/autoload/output/alsa_output.pci-0000_65_00.6.analog-stereo:analog-output-headphones.json".text = builtins.toJSON {
      device = "alsa_output.pci-0000_65_00.6.analog-stereo";
      device-description = "Ryzen HD Audio Controller Analog Stereo";
      device-profile = "analog-output-headphones";
      preset-name = "Blank";
    };
  };
}
