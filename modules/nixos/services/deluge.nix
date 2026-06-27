{ config, pkgs, ... }:

{
  # Deluge runs as its own system user by default
  services.deluge = {
    enable = true;
    openFirewall = true;      # open daemon + web UI ports
    web.enable = true;        # enable Deluge Web UI
    # Optional: explicit data dir
    # dataDir = "/var/lib/deluge";
  };

  # (Optional, but keeps things tidy locally)
  users.groups.media.members = [ "deluge" ];
}
