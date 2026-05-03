{ pkgs, ... }:
{
  boot.kernelParams = [ "consoleblank=300" ];

  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };
  console.keyMap = "fr";

  networking.networkmanager.enable = true;
  
  services.logind.lidSwitch = "ignore";

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}
