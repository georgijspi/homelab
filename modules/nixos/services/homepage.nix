{ config, lib, vars, ... }:

let
  domainHosts = vars.domain.hosts;
  services = vars.services;
  storage = vars.storage;
  homepage = services.homepage;

  httpUrl = host: port: "http://${host}:${toString port}";
  httpsUrl = host: "https://${host}";
  compactCard = {
    showStats = true;
    statusStyle = "dot";
    target = "_self";
  };
in
{
  sops.secrets = {
    homepage_jellyfin_api_key.restartUnits = [ "homepage-dashboard.service" ];
    homepage_adguard_api_key.restartUnits = [ "homepage-dashboard.service" ];
  };

  sops.templates."homepage.env" = {
    content = ''
      HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder.homepage_jellyfin_api_key}
      HOMEPAGE_VAR_ADGUARD_API_KEY=${config.sops.placeholder.homepage_adguard_api_key}
    '';
    mode = "0400";
    restartUnits = [ "homepage-dashboard.service" ];
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = homepage.port;
    allowedHosts = lib.concatStringsSep "," homepage.allowedHosts;
    environmentFiles = [ config.sops.templates."homepage.env".path ];
    openFirewall = true;

    widgets = [
      {
        greeting = {
          text = "Falcon";
          text_size = "2xl";
        };
      }
      {
        resources = {
          label = "Host";
          cpu = true;
          memory = true;
          disk = [
            "/"
            storage.nasMediaMount
          ];
          uptime = true;
          refresh = 3000;
          diskUnits = "bytes";
        };
      }
      {
        openmeteo = {
          label = "Dublin";
          latitude = 53.3498;
          longitude = -6.2603;
          timezone = vars.host.timeZone;
          units = "metric";
          cache = 15;
          format.maximumFractionDigits = 1;
        };
      }
      {
        datetime = {
          locale = "en-IE";
          text_size = "xl";
          format = {
            weekday = "short";
            day = "2-digit";
            month = "short";
            hour = "2-digit";
            minute = "2-digit";
            hourCycle = "h23";
          };
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    services = [
      {
        "Command Center" = [
          {
            "Falcon" = compactCard // {
              href = httpsUrl domainHosts.homepage;
              description = "NixOS 26.05 / ${vars.host.system} / ${vars.network.hostAddress}";
              icon = "mdi-server";
              ping = httpUrl "127.0.0.1" homepage.port;
            };
          }
          {
            "Traefik" = compactCard // {
              href = httpsUrl domainHosts.traefik;
              description = "Reverse proxy and TLS";
              icon = "traefik.png";
              ping = "https://${vars.network.hostAddress}";
            };
          }
          {
            "AdGuard Home" = compactCard // {
              href = httpsUrl domainHosts.adguard;
              description = "DNS filtering";
              icon = "sh-adguard-home";
              ping = httpUrl services.adguard.host services.adguard.port;
              widget = {
                type = "adguard";
                url = httpUrl services.adguard.host services.adguard.port;
                key = "{{HOMEPAGE_VAR_ADGUARD_API_KEY}}";
              };
            };
          }
          {
            "Deluge" = compactCard // {
              href = httpsUrl domainHosts.deluge;
              description = "Torrent client";
              icon = "deluge.png";
              ping = services.deluge.webUrl;
            };
          }
          {
            "NAS" = compactCard // {
              href = httpsUrl domainHosts.omv;
              description = "${storage.nasMediaMount} from ${storage.nasAddress}";
              icon = "openmediavault.png";
              ping = storage.nasAddress;
            };
          }
          {
            "Router" = compactCard // {
              href = "http://${vars.network.gateway}";
              description = "Gateway";
              icon = "router.png";
              ping = vars.network.gateway;
            };
          }
        ];
      }

      {
        "Media Automation" = [
          {
            "Sonarr" = compactCard // {
              href = httpsUrl domainHosts.sonarr;
              description = "TV automation";
              icon = "sonarr.png";
              ping = httpUrl services.sonarr.host services.sonarr.port;
            };
          }
          {
            "Radarr" = compactCard // {
              href = httpsUrl domainHosts.radarr;
              description = "Movie automation";
              icon = "radarr.png";
              ping = httpUrl services.radarr.host services.radarr.port;
            };
          }
          {
            "Prowlarr" = compactCard // {
              href = httpsUrl domainHosts.prowlarr;
              description = "Indexers for Arr apps";
              icon = "prowlarr.png";
              ping = httpUrl services.prowlarr.host services.prowlarr.port;
            };
          }
          {
            "Bazarr" = compactCard // {
              href = httpsUrl domainHosts.bazarr;
              description = "Subtitle automation";
              icon = "bazarr.png";
              ping = httpUrl services.bazarr.host services.bazarr.port;
            };
          }
        ];
      }

      {
        "Media Library" = [
          {
            "Jellyfin" = compactCard // {
              href = httpsUrl domainHosts.jellyfin;
              description = "Movies and shows";
              icon = "jellyfin.png";
              ping = httpUrl services.jellyfin.host services.jellyfin.port;
              widget = {
                type = "jellyfin";
                url = httpUrl services.jellyfin.host services.jellyfin.port;
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                enableBlocks = true;
                enableNowPlaying = true;
              };
            };
          }
          {
            "Audiobookshelf" = compactCard // {
              href = httpsUrl domainHosts.audiobookshelf;
              description = "Audiobooks and podcasts";
              icon = "audiobookshelf.png";
              ping = httpUrl services.audiobookshelf.host services.audiobookshelf.port;
            };
          }
          {
            "Immich" = compactCard // {
              href = httpsUrl domainHosts.immich;
              description = "Photos and videos";
              icon = "immich.png";
              ping = httpUrl services.immich.host services.immich.port;
            };
          }
        ];
      }
      {
        "Apps & Games" = [
          {
            "Copyparty" = compactCard // {
              href = httpsUrl domainHosts.copyparty;
              description = "LAN file drop";
              icon = "mdi-file-upload";
              ping = httpUrl services.copyparty.host services.copyparty.port;
            };
          }
          {
            "Tiny Tiny RSS" = compactCard // {
              href = httpsUrl domainHosts.ttRss;
              description = "RSS reader";
              icon = "mdi-rss";
              ping = httpUrl services.ttRss.host services.ttRss.port;
            };
          }
          {
            "Minecraft" = compactCard // {
              href = "tcp://${vars.network.hostAddress}:${toString services.minecraft.port}";
              description = "Paper server";
              icon = "minecraft.png";
              ping = "udp://${vars.network.hostAddress}:${toString services.minecraft.port}";
              widget = {
                type = "minecraft";
                url = "udp://${vars.network.hostAddress}:${toString services.minecraft.port}";
              };
            };
          }
        ];
      }
    ];

    settings = {
      color = "zinc";
      title = "Falcon Server";
      description = "NixOS services, media, and network tools";
      favicon = "https://github.com/walkxcode.png";
      headerStyle = "boxedWidgets";
      hideVersion = true;
      theme = "dark";
      target = "_self";
      iconStyle = "theme";
      fullWidth = true;
      maxGroupColumns = 3;
      disableCollapse = true;
      useEqualHeights = true;
      layout = {
        "Command Center" = {
          icon = "mdi-view-dashboard";
          style = "row";
          columns = 6;
        };
        "Media Library" = {
          icon = "mdi-play-box-multiple";
          style = "row";
          columns = 3;
        };
        "Media Automation" = {
          icon = "mdi-robot";
          style = "row";
          columns = 4;
        };
        "Apps & Games" = {
          icon = "mdi-apps";
          style = "row";
          columns = 3;
        };
      };
    };

    customCSS = ''
      /* Falcon AMOLED glass */
      :root {
        --g-surface: linear-gradient(155deg, rgba(255, 255, 255, 0.065) 0%, rgba(255, 255, 255, 0.02) 100%);
        --g-surface-hover: linear-gradient(155deg, rgba(255, 255, 255, 0.09) 0%, rgba(255, 255, 255, 0.032) 100%);
        --g-border: rgba(255, 255, 255, 0.1);
        --g-border-hover: rgba(74, 222, 128, 0.3);
        --g-shine: rgba(255, 255, 255, 0.14);
        --g-blur: blur(20px) saturate(155%);
        --g-shadow: 0 6px 28px rgba(0, 0, 0, 0.8), 0 2px 6px rgba(0, 0, 0, 0.5);
        --g-shadow-hover: 0 10px 40px rgba(0, 0, 0, 0.9), 0 0 22px rgba(74, 222, 128, 0.1);
        --green: rgb(74, 222, 128);
        --green-soft: rgba(74, 222, 128, 0.88);
        --text: rgba(255, 255, 255, 0.9);
      }

      /* True black background */
      html,
      body,
      #__next {
        background: #000 !important;
        color: var(--text);
      }

      /* Page container */
      #page_container {
        max-width: none !important;
        padding: 0.85rem clamp(0.7rem, 2vw, 1.75rem) 1.5rem !important;
      }

      /* Widget bar */
      #information-widgets {
        gap: 0.55rem !important;
        margin-bottom: 0.7rem !important;
      }

      #information-widgets > * {
        background: var(--g-surface) !important;
        border: 1px solid var(--g-border) !important;
        border-radius: 14px !important;
        box-shadow: inset 0 1px 0 var(--g-shine), var(--g-shadow);
        backdrop-filter: var(--g-blur);
        -webkit-backdrop-filter: var(--g-blur);
      }

      /* Greeting */
      .information-widget-greeting {
        color: var(--green) !important;
      }

      /* Group headings */
      #page_container h2 {
        color: var(--green-soft) !important;
        letter-spacing: 0.03em !important;
      }

      #page_container h3 {
        color: var(--text) !important;
        letter-spacing: 0 !important;
      }

      /* Service cards */
      #page_container ul {
        gap: 0.55rem !important;
      }

      #page_container li > a,
      #page_container li > div {
        background: var(--g-surface) !important;
        border: 1px solid var(--g-border) !important;
        border-radius: 14px !important;
        box-shadow: inset 0 1px 0 var(--g-shine), var(--g-shadow);
        backdrop-filter: var(--g-blur);
        -webkit-backdrop-filter: var(--g-blur);
        transition: border-color 150ms ease, box-shadow 150ms ease, transform 130ms ease, background 150ms ease;
      }

      #page_container li > a:hover,
      #page_container li > div:hover {
        background: var(--g-surface-hover) !important;
        border-color: var(--g-border-hover) !important;
        box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.18), var(--g-shadow-hover);
        transform: translateY(-1px);
      }

      /* Text */
      #page_container p,
      #page_container span {
        color: inherit;
      }

      /* Icon glow */
      #page_container img,
      #page_container svg {
        filter: drop-shadow(0 0 6px rgba(34, 197, 94, 0.06));
      }

      /* Footer */
      #footer,
      #version,
      .homepage-version {
        opacity: 0.3;
      }

      /* Mobile */
      @media (max-width: 768px) {
        #page_container {
          padding-inline: 0.65rem !important;
        }

        #information-widgets {
          gap: 0.45rem !important;
        }
      }
    '';
  };
}
