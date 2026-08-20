{ ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  users.users.rain.extraGroups = [
    "uinput"
    "input"
  ];
}
