{ config, pkgs, infra, ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "processes"
      "cpu"
      "meminfo"
      "hwmon"
      "powersupplyclass"
      "thermal_zone"
      "cpufreq"
      "tailscale"
    ];
    port = 9100;
  };

  services.vmagent = {
    enable = true;
    remoteWrite.url = infra.prometheus.url;

    extraArgs = [
      "-remoteWrite.tmpDataPath=/var/lib/vmagent-buffer"
      "-remoteWrite.maxDiskUsagePerURL=1GB"
    ];

    prometheusConfig = {
      global.scrape_interval = "15s";
      scrape_configs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            {
              targets = [ "127.0.0.1:9100" ];
              labels.hostname = config.networking.hostName;
            }
          ];
        }
      ];
    };
  };

  systemd.services.vmagent.serviceConfig = {
    StateDirectory = "vmagent-buffer";
    ReadWritePaths = [ "/var/lib/vmagent-buffer" ];
  };
}
