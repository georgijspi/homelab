{ vars, ... }:

let
  mediaMount = vars.storage.nasMediaMount;
  services = vars.services;
in
{
  # Expected NAS layout configured in the Arr UIs:
  #   ${mediaMount}/downloads/torrents/tv
  #   ${mediaMount}/downloads/torrents/movies
  #   ${mediaMount}/downloads/torrents/anime-series
  #   ${mediaMount}/media/tv
  #   ${mediaMount}/media/movies
  #   ${mediaMount}/media/anime/series
  #
  # Keep downloads and final libraries on the same mount so Sonarr/Radarr can
  # hardlink completed files while Deluge continues seeding.

  services.deluge.group = "media";

  services.sonarr = {
    enable = true;
    openFirewall = false;
    group = "media";
    settings.server = {
      port = services.sonarr.port;
      bindaddress = services.sonarr.host;
    };
  };

  services.radarr = {
    enable = true;
    openFirewall = false;
    group = "media";
    settings.server = {
      port = services.radarr.port;
      bindaddress = services.radarr.host;
    };
  };

  services.prowlarr = {
    enable = true;
    openFirewall = false;
    settings.server = {
      port = services.prowlarr.port;
      bindaddress = services.prowlarr.host;
    };
  };

  services.bazarr = {
    enable = true;
    openFirewall = false;
    listenPort = services.bazarr.port;
    group = "media";
  };

  users.groups.media.members = [
    "deluge"
    "jellyfin"
    "sonarr"
    "radarr"
    "bazarr"
  ];

  systemd.services = {
    deluged.unitConfig.RequiresMountsFor = [ mediaMount ];
    delugeweb.unitConfig.RequiresMountsFor = [ mediaMount ];
    sonarr.unitConfig.RequiresMountsFor = [ mediaMount ];
    radarr.unitConfig.RequiresMountsFor = [ mediaMount ];
    bazarr.unitConfig.RequiresMountsFor = [ mediaMount ];
  };

  systemd.tmpfiles.rules = [
    "d ${mediaMount}/downloads 0775 root media -"
    "d ${mediaMount}/downloads/torrents 0775 root media -"
    "d ${mediaMount}/downloads/torrents/tv 0775 root media -"
    "d ${mediaMount}/downloads/torrents/movies 0775 root media -"
    "d ${mediaMount}/downloads/torrents/anime-series 0775 root media -"
    "d ${mediaMount}/media 0775 root media -"
    "d ${mediaMount}/media/tv 0775 root media -"
    "d ${mediaMount}/media/movies 0775 root media -"
    "d ${mediaMount}/media/anime 0775 root media -"
    "d ${mediaMount}/media/anime/series 0775 root media -"
  ];
}
