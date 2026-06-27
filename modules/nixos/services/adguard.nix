{ vars, ... }:

{
  services.adguardhome = {
    enable = true;
    host = vars.services.adguard.host;
    port = vars.services.adguard.port;

    settings = {
      dns.upstream_dns = [
        "https://1.1.1.1/dns-query"
        "https://8.8.8.8/dns-query"
      ];

      filters = [
        {
          id = 1;
          name = "AdGuard Base filter";
          url = "https://filters.adguard.com/extension/index.min.css";
          enabled = true;
        }
      ];
    };
  };
}
