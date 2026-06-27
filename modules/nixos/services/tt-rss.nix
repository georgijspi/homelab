{ vars, ... }:

{
  services.tt-rss = {
    enable = true;
    virtualHost = "tt-rss";
    selfUrlPath = "https://${vars.domain.hosts.ttRss}/";
    database = {
      type = "pgsql";
      createLocally = true;
    };
  };

  services.nginx.virtualHosts."tt-rss" = {
    listen = [
      {
        addr = vars.services.ttRss.host;
        port = vars.services.ttRss.port;
      }
    ];
  };
}
