{ config, vars, ... }:

let
  domain = vars.domain;
  hosts = domain.hosts;
  services = vars.services;

  hostRule = host: "Host(`${host}`)";
  httpUrl = host: port: "http://${host}:${toString port}";
  tomlStringArray = values: "[ ${builtins.concatStringsSep ", " (map (value: "\"${value}\"") values)} ]";
  lanSourceRanges = [
    vars.network.lanCidr
    vars.network.wireguard.ipv4Cidr
    vars.network.wireguard.ipv6Cidr
    "127.0.0.1/32"
    "::1/128"
  ];
in
{
  sops.secrets = {
    cloudflare_api_token.restartUnits = [ "traefik.service" ];
    basic_auth_traefik.restartUnits = [ "traefik.service" ];
    basic_auth_adguard.restartUnits = [ "traefik.service" ];
  };

  sops.templates."traefik.env" = {
    content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_token}
    '';
    owner = "traefik";
    group = "traefik";
    mode = "0400";
    restartUnits = [ "traefik.service" ];
  };

  sops.templates."traefik-dynamic.toml" = {
    content = ''
      [http.middlewares.traefik-auth.basicAuth]
        users = [ "${config.sops.placeholder.basic_auth_traefik}" ]

      [http.middlewares.adguard-auth.basicAuth]
        users = [ "${config.sops.placeholder.basic_auth_adguard}" ]

      [http.middlewares.forwarded-headers.headers.customRequestHeaders]
        X-Forwarded-Proto = "https"

      [http.middlewares.lan-only.ipAllowList]
        sourceRange = ${tomlStringArray lanSourceRanges}

      [http.routers.dashboard]
        rule = "${hostRule hosts.traefik}"
        service = "api@internal"
        entryPoints = [ "websecure" ]
        middlewares = [ "traefik-auth" ]

      [http.routers.dashboard.tls]
        certResolver = "cloudflare"

      [http.routers.homepage]
        rule = "${hostRule hosts.homepage}"
        service = "homepage-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.homepage.tls]
        certResolver = "cloudflare"

      [http.routers.omv-dashboard]
        rule = "${hostRule hosts.omv}"
        service = "omv-service"
        entryPoints = [ "websecure" ]

      [http.routers.omv-dashboard.tls]
        certResolver = "cloudflare"

      [http.routers.adguard-web]
        rule = "${hostRule hosts.adguard}"
        service = "adguard-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "adguard-auth" ]

      [http.routers.adguard-web.tls]
        certResolver = "cloudflare"

      [http.routers.deluge-lan]
        rule = "${hostRule hosts.deluge}"
        service = "deluge-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.deluge-lan.tls]
        certResolver = "cloudflare"

      [http.routers.sonarr-lan]
        rule = "${hostRule hosts.sonarr}"
        service = "sonarr-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.sonarr-lan.tls]
        certResolver = "cloudflare"

      [http.routers.radarr-lan]
        rule = "${hostRule hosts.radarr}"
        service = "radarr-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.radarr-lan.tls]
        certResolver = "cloudflare"

      [http.routers.prowlarr-lan]
        rule = "${hostRule hosts.prowlarr}"
        service = "prowlarr-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.prowlarr-lan.tls]
        certResolver = "cloudflare"

      [http.routers.bazarr-lan]
        rule = "${hostRule hosts.bazarr}"
        service = "bazarr-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.bazarr-lan.tls]
        certResolver = "cloudflare"

      [http.routers.jellyfin-wan]
        rule = "${hostRule hosts.jellyfin}"
        service = "jellyfin-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.jellyfin-wan.tls]
        certResolver = "cloudflare"

      [http.routers.audiobookshelf-wan]
        rule = "${hostRule hosts.audiobookshelf}"
        service = "audiobookshelf-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.audiobookshelf-wan.tls]
        certResolver = "cloudflare"

      [http.routers.immich-wan]
        rule = "${hostRule hosts.immich}"
        service = "immich-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.immich-wan.tls]
        certResolver = "cloudflare"

      [http.routers.copyparty-lan]
        rule = "${hostRule hosts.copyparty}"
        service = "copyparty-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.copyparty-lan.tls]
        certResolver = "cloudflare"

      [http.routers.tt-rss-wan]
        rule = "${hostRule hosts.ttRss}"
        service = "tt-rss-service"
        entryPoints = [ "websecure" ]
        middlewares = [ "forwarded-headers" ]

      [http.routers.tt-rss-wan.tls]
        certResolver = "cloudflare"

      [http.routers.zellij-lan]
        rule = "${hostRule hosts.zellij}"
        service = "zellij-service"
        entryPoints = [ "websecure" ]
        middlewares = ${tomlStringArray [ "lan-only" "forwarded-headers" ]}

      [http.routers.zellij-lan.tls]
        certResolver = "cloudflare"

      [[http.services.homepage-service.loadBalancer.servers]]
        url = "${httpUrl "127.0.0.1" services.homepage.port}"

      [[http.services.omv-service.loadBalancer.servers]]
        url = "http://${vars.storage.nasAddress}"

      [[http.services.adguard-service.loadBalancer.servers]]
        url = "${httpUrl services.adguard.host services.adguard.port}"

      [[http.services.jellyfin-service.loadBalancer.servers]]
        url = "${httpUrl services.jellyfin.host services.jellyfin.port}"

      [[http.services.deluge-service.loadBalancer.servers]]
        url = "${services.deluge.webUrl}"

      [[http.services.sonarr-service.loadBalancer.servers]]
        url = "${httpUrl services.sonarr.host services.sonarr.port}"

      [[http.services.radarr-service.loadBalancer.servers]]
        url = "${httpUrl services.radarr.host services.radarr.port}"

      [[http.services.prowlarr-service.loadBalancer.servers]]
        url = "${httpUrl services.prowlarr.host services.prowlarr.port}"

      [[http.services.bazarr-service.loadBalancer.servers]]
        url = "${httpUrl services.bazarr.host services.bazarr.port}"

      [[http.services.audiobookshelf-service.loadBalancer.servers]]
        url = "${httpUrl services.audiobookshelf.host services.audiobookshelf.port}"

      [[http.services.immich-service.loadBalancer.servers]]
        url = "${httpUrl services.immich.host services.immich.port}"

      [[http.services.copyparty-service.loadBalancer.servers]]
        url = "${httpUrl services.copyparty.host services.copyparty.port}"

      [[http.services.tt-rss-service.loadBalancer.servers]]
        url = "${httpUrl services.ttRss.host services.ttRss.port}"

      [[http.services.zellij-service.loadBalancer.servers]]
        url = "${httpUrl services.zellij.host services.zellij.port}"
    '';
    owner = "traefik";
    group = "traefik";
    mode = "0400";
    restartUnits = [ "traefik.service" ];
  };

  users.users.traefik = {
    isSystemUser = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.traefik = {
    enable = true;
    environmentFiles = [ config.sops.templates."traefik.env".path ];
    dynamicConfigFile = config.sops.templates."traefik-dynamic.toml".path;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "cloudflare";
            domains = [
              { main = domain.root; sans = [ "*.${domain.root}" ]; }
              { main = domain.localRoot; sans = [ "*.${domain.localRoot}" ]; }
            ];
          };
        };
        lansecure = {
          address = ":8443";
          http.tls = {
            certResolver = "cloudflare";
            domains = [
              { main = domain.localRoot; sans = [ "*.${domain.localRoot}" ]; }
            ];
          };
        };
      };

      certificatesResolvers.cloudflare.acme = {
        email = domain.acmeEmail;
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
          delayBeforeCheck = 90;
        };
      };

      api.dashboard = true;

      # The dynamic config is rendered under /run/secrets by sops-nix.
      # Traefik can read it, but cannot watch that protected path directly.
      providers.file.watch = false;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/traefik 0755 traefik traefik -"
  ];
}
