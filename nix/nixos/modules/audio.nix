{ config, lib, pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  environment.systemPackages = with pkgs; [
    alsa-utils
    pulseaudio
    roc-toolkit
    socat
  ];

  users.users.rain.linger = true;

  systemd.user.services.dbus-broker.restartIfChanged = false;

  systemd.user.services.pipewire-raw-audio-bridge = let
    pacatWrapper = pkgs.writeShellScript "pacat-raw-playback" ''
      exec ${pkgs.pulseaudio}/bin/pacat --playback --raw --latency-msec=20
    '';
  in {
    description = "Raw PCM audio streaming bridge (TCP:4714 → pacat)";
    after = [ "pipewire-pulse.service" ];
    bindsTo = [ "pipewire-pulse.service" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:4714,reuseaddr,fork EXEC:${pacatWrapper}";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    # debug stuff
    extraConfig."pipewire-pulse"."10-tcp-server" = {
      "pulse.properties" = {
        "server.address" = [ 
          "unix:native" 
          "tcp:0.0.0.0:4713"
        ];
      };
    };

    extraConfig.pipewire."10-pw-network" = {
      "context.modules" = [
        {
          name = "libpipewire-module-protocol-native";
          args = { } ;
          flags = [ "ifexists" "nofail" ];
        }
      ];
      "context.properties" = {
        "core.daemon" = true;
        "core.name" = "pipewire-0";
        "server.address" = [
          "unix:native"
          "tcp:0.0.0.0:4712"
        ];
      };
    };

    # real low latency audio streaming
    extraConfig.pipewire."99-roc-source" = {
      "context.modules" = [
        {
          name = "libpipewire-module-roc-source";
          args = {
            local.ip = "0.0.0.0";
            resampler.profile = "medium";
            sess.latency.msec = 30;
            local.source.port = 10001;
            local.repair.port = 10002;
            local.control.port = 10003;
          };
        }
      ];
    };

    extraConfig.pipewire."20-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 128;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 512;
      };
    };

    wireplumber = {
      extraConfig."10-bluetooth-latency" = {
        "monitor.bluez.properties" = {
          "bluez5.codecs" = [ "aac" "sbc" "sbc_xq" ];
          "bluez5.roles" = [ "a2dp_sink" "a2dp_source" ];
        };
        "monitor.bluez.rules" = [
          {
            matches = [ { "node.name" = "~bluez_card.*"; } ];
            actions = {
              update-props = {
                "api.bluez5.a2dp.quantum" = 512;
              };
            };
          }
        ];
      };

      extraConfig."50-bluez-no-seat" = {
        "wireplumber.profiles" = {
          "main" = {
            "monitor.bluez.seat-monitoring" = "disabled";
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 4712 4713 4714 ];
  networking.firewall.allowedUDPPorts = [ 10001 10002 10003 ];
}