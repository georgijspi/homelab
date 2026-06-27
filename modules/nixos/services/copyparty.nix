{ config, vars, ... }:

let
  userName = vars.host.primaryUser.name;
in
{
  sops.secrets.copyparty_zx_password = {
    owner = "copyparty";
    group = "copyparty";
    mode = "0400";
    restartUnits = [ "copyparty.service" ];
  };

  services.copyparty = {
    enable = true;

    settings = {
      i = vars.services.copyparty.host;
      p = [ vars.services.copyparty.port ];
    };

    accounts.${userName}.passwordFile = config.sops.secrets.copyparty_zx_password.path;

    volumes."/" = {
      path = vars.storage.nasMediaMount;
      access.rwmda = userName;
    };
  };

  systemd.services.copyparty.unitConfig = {
    RequiresMountsFor = [ vars.storage.nasMediaMount ];
  };

  systemd.tmpfiles.rules = [
    "d ${vars.storage.nasMediaMount} 0755 root root - -"
  ];
}
