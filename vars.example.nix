{
  host = {
    name = "example-host";
    system = "x86_64-linux";
    timeZone = "Etc/UTC";
    primaryUser = {
      name = "example-user";
      description = "Example User";
    };
  };

  git = {
    user = {
      name = "Example User";
      email = "user@example.invalid";
    };
  };

  domain = {
    root = "example.invalid";
    localRoot = "local.example.invalid";
    acmeEmail = "admin@example.invalid";
    hosts = {
      root = "example.invalid";
      home = "home.example.invalid";
      wireguard = "wg.example.invalid";
      minecraft = "mc.example.invalid";
      homepage = "host.example.invalid";
      traefik = "traefik.local.example.invalid";
      omv = "nas.local.example.invalid";
      adguard = "dns.local.example.invalid";
      deluge = "deluge.local.example.invalid";
      sonarr = "sonarr.local.example.invalid";
      radarr = "radarr.local.example.invalid";
      prowlarr = "prowlarr.local.example.invalid";
      bazarr = "bazarr.local.example.invalid";
      jellyfin = "jellyfin.example.invalid";
      audiobookshelf = "books.example.invalid";
      immich = "photos.example.invalid";
      copyparty = "files.local.example.invalid";
      ttRss = "rss.example.invalid";
      zellij = "zellij.local.example.invalid";
    };
  };

  network = {
    interface = "enp0s1";
    hostAddress = "10.0.0.10";
    prefixLength = 24;
    lanCidr = "10.0.0.0/24";
    gateway = "10.0.0.1";
    nameservers = [ "10.0.0.10" "1.1.1.1" ];

    firewall = {
      baseAllowedTCPPorts = [ 22 80 443 8080 53 8443 8096 8112 30033 ];
      baseAllowedUDPPorts = [ 53 9987 ];
      lanOnlyTCPPorts = [ 8443 53 8080 8112 ];
      lanOnlyUDPPorts = [ 53 ];
    };

    wireguard = {
      keyPath = "/home/example-user/wireguard-keys";
      ipv4Cidr = "10.99.0.0/24";
      ipv6Cidr = "fd00::/56";
      serverIPv4 = "10.99.0.1/24";
      serverIPv6 = "fd00::1";
      listenPort = 51820;
      externalInterface = "enp0s1";
      natPostroutingInterface = "enp0s1";
      peers = [
        {
          name = "example-client";
          publicKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          allowedIPs = [ "10.99.0.2/32" "fd00::2/128" ];
        }
      ];
    };
  };

  storage = {
    nasAddress = "10.0.0.20";
    nasExport = "/export/media";
    nasMediaMount = "/mnt/nas-media";
  };

  services = {
    homepage = {
      port = 8082;
      allowedHosts = [
        "10.0.0.10"
        "example-host"
        "127.0.0.1"
        "host.example.invalid"
      ];
      glancesUrl = "http://10.0.0.10:61208";
    };
    adguard = {
      host = "10.0.0.10";
      port = 8080;
    };
    jellyfin = {
      host = "10.0.0.10";
      port = 8096;
    };
    audiobookshelf = {
      host = "127.0.0.1";
      port = 8000;
    };
    immich = {
      host = "127.0.0.1";
      port = 2283;
    };
    copyparty = {
      host = "127.0.0.1";
      port = 3923;
    };
    deluge = {
      webUrl = "http://10.0.0.10:8112";
    };
    sonarr = {
      host = "127.0.0.1";
      port = 8989;
    };
    radarr = {
      host = "127.0.0.1";
      port = 7878;
    };
    prowlarr = {
      host = "127.0.0.1";
      port = 9696;
    };
    bazarr = {
      host = "127.0.0.1";
      port = 6767;
    };
    minecraft = {
      port = 25565;
    };
    ttRss = {
      host = "127.0.0.1";
      port = 8280;
    };
    zellij = {
      host = "127.0.0.1";
      port = 8083;
    };
  };

  ddclient = {
    domains = [
      "home.example.invalid"
      "wg.example.invalid"
      "mc.example.invalid"
    ];
  };
}
