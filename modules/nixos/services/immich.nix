{ vars, ... }:

let
  mediaLocation = "${vars.storage.nasMediaMount}/immich";
in
{
  services.immich = {
    enable = true;
    host = vars.services.immich.host;
    port = vars.services.immich.port;
    mediaLocation = mediaLocation;
    accelerationDevices = null;

    database = {
      enable = true;
      createDB = true;
    };

    redis.enable = true;
    machine-learning.enable = true;
  };

  users.users.immich.extraGroups = [ "video" "render" ];

  systemd.tmpfiles.rules = [
    "d ${mediaLocation} 0750 immich immich -"
  ];
}
