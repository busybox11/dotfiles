{ ... }:
{
  services.adguardhome = {
    enable = true;
    port = 5335;
    settings = {
      http = {
        address = "0.0.0.0:5335";
      };
      dns = {
        upstream_dns = [
          "https://dns.nextdns.io"
          "tls://dns.nextdns.io"
          "1.1.1.1"
          "1.0.0.1"
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
          "tls://one.one.one.one"
          "tls://dns.google"
          "192.168.1.254" # internal dns server
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search = {
          enabled = false;
        };
      };
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
        "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.mini.txt"
      ];
    };
  };
}
