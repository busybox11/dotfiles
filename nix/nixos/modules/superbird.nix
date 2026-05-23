username:
{ ... }:
{
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1b8e", ATTRS{idProduct}=="c003", OWNER="${username}", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="1014", OWNER="${username}", MODE="0666"
  '';
}
