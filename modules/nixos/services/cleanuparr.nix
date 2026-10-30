{ lib, pkgs, vars, ... }:

let
  cleanuparr = pkgs.callPackage ../../../packages/cleanuparr.nix { };
in
{
  users.groups.cleanuparr = { };
  users.users.cleanuparr = {
    isSystemUser = true;
    group = "cleanuparr";
    home = "/var/lib/cleanuparr";
  };

  systemd.services.cleanuparr = {
    description = "Cleanuparr download queue cleaner";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = {
      PORT = "11011";
      BIND_ADDRESS = "127.0.0.1";
      BASE_PATH = "";
      TZ = vars.host.timeZone;
      CLEANUPARR_CONFIG_PATH = "/var/lib/cleanuparr/config";
      CLEANUPARR_LOGS_PATH = "/var/lib/cleanuparr/logs";
    };

    serviceConfig = {
      Type = "simple";
      User = "cleanuparr";
      Group = "cleanuparr";
      StateDirectory = "cleanuparr";
      StateDirectoryMode = "0750";
      WorkingDirectory = "/var/lib/cleanuparr";
      ExecStart = lib.getExe cleanuparr;
      Restart = "on-failure";
      RestartSec = 5;

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
    };
  };
}
