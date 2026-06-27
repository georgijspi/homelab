{ config, lib, vars, ... }:

{
  sops.secrets.ddclient_cloudflare_api_token = {
    key = "cloudflare_api_token";
    owner = "ddclient";
    group = "ddclient";
    mode = "0400";
    restartUnits = [ "ddclient.service" ];
  };

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    username = "token";
    passwordFile = config.sops.secrets.ddclient_cloudflare_api_token.path;
    zone = vars.domain.root;
    domains = vars.ddclient.domains;
    usev4 = "webv4, webv4=ipify-ipv4";
    usev6 = "";
    interval = "5min";
    ssl = true;
  };

  users.groups.ddclient = {};
  users.users.ddclient = {
    isSystemUser = true;
    group = "ddclient";
  };

  systemd.services.ddclient.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ddclient";
    Group = "ddclient";
  };
}
