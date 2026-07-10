{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.usbip;
  btVendor = "8087";
  btProduct = "0026";

  bindScript = pkgs.writeShellScript "usbip-bind-bt" ''
    set -euo pipefail
    VENDOR="${btVendor}"
    PRODUCT="${btProduct}"
    export PATH="${pkgs.kmod}/bin:${pkgs.linuxPackages.usbip}/bin:$PATH"
    # Load usbip_host if not already present.
    if [ ! -d /sys/bus/usb/drivers/usbip-host ]; then
      timeout 5 modprobe usbip_host 2>/dev/null || true
    fi
    # Wait for module to be ready
    for i in $(seq 1 10); do
      [ -d /sys/bus/usb/drivers/usbip-host ] && break
      sleep 1
    done
    [ -d /sys/bus/usb/drivers/usbip-host ] || { echo "usbip_host not available, skipping" >&2; exit 0; }
    # Find the device in sysfs by VID:PID
    BUSID=""
    for dev in /sys/bus/usb/devices/*/idVendor; do
      [ -f "$dev" ] || continue
      V="$(cat "$dev" 2>/dev/null || true)"
      [ "$V" = "$VENDOR" ] || continue
      d="''${dev%/idVendor}"
      P="$(cat "$d/idProduct" 2>/dev/null || true)"
      if [ "$P" = "$PRODUCT" ]; then
        BUSID="$(basename "$d")"
        break
      fi
    done
    [ -n "$BUSID" ] || { echo "AX201 BT ($VENDOR:$PRODUCT) not found" >&2; exit 0; }
    # Check if already bound to usbip-host; skip if so
    if [ -L "/sys/bus/usb/drivers/usbip-host/$BUSID" ]; then
      echo "$BUSID already bound to usbip-host" >&2
      exit 0
    fi
    # Unbind interfaces from btusb first, then bind via usbip
    shopt -s nullglob
    for iface in /sys/bus/usb/devices/"$BUSID"/*/driver; do
      d="$(dirname "$iface")"
      echo "$(basename "$d")" > "$d/driver/unbind" 2>/dev/null || true
    done
    usbip bind -b "$BUSID" 2>&1 || true
    echo "Bound $BUSID ($VENDOR:$PRODUCT) to usbip_host"
  '';
in
{
  options.services.usbip = {
    enable = mkEnableOption "USB/IP server (usbipd)";
    forwardBt = mkOption {
      type = types.bool;
      default = false;
      description = "Forward Intel AX201 Bluetooth (8087:0026) to USB/IP (unreliable with Intel BT)";
    };
    btProxy = {
      enable = mkEnableOption "Bluetooth HCI proxy (btproxy) for AX201";
      port = mkOption {
        type = types.port;
        default = 4242;
        description = "TCP port for btproxy";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ pkgs.linuxPackages.usbip ];

    environment.systemPackages = with pkgs; [
      linuxPackages.usbip
      kmod
    ];

    networking.firewall.allowedTCPPorts = [ 3240 ] ++ optional cfg.btProxy.enable cfg.btProxy.port;

    systemd.services.usbipd = {
      description = "USB/IP server daemon";
      after = [ "network.target" ];
      wants = optional (cfg.forwardBt) "usbip-bind-bt.service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.linuxPackages.usbip}/bin/usbipd -D -P /run/usbipd.pid";
        PIDFile = "/run/usbipd.pid";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeMaxSec = 30;
      };
    };

    systemd.services.usbip-bind-bt = mkIf cfg.forwardBt {
      description = "Bind Intel AX201 Bluetooth to usbip_host";
      partOf = [ "usbipd.service" ];
      wantedBy = [ "usbipd.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${bindScript}";
        RemainAfterExit = true;
        RuntimeMaxSec = 30;
      };
    };

    systemd.services.btproxy = mkIf cfg.btProxy.enable {
      description = "Bluetooth HCI proxy for AX201";
      conflicts = [ "bluetooth.service" ];
      after = [ "bluetooth.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.bluez}/bin/btproxy -l -p ${toString cfg.btProxy.port} -i 0";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
