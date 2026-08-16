# Systemd settings for services that need the NAS media mount.
#
# RequiresMountsFor pulls in the noauto mount unit itself, so when the NAS
# loses the boot race (e.g. after a power cut hits both machines) the mount
# fails once and every dependent service is left dead with no retry.
# Depending on the automount unit instead always succeeds at boot; the
# ExecStartPre probe then triggers the actual mount and keeps the service
# retrying until the NAS answers.
{ lib, pkgs, utils, vars }:

let
  mediaMount = vars.storage.nasMediaMount;
  automountUnit = "${utils.escapeSystemdPath mediaMount}.automount";
in
{
  requires = [ automountUnit ];
  after = [ automountUnit ];
  unitConfig.StartLimitIntervalSec = 0;
  serviceConfig = {
    ExecStartPre = "${pkgs.coreutils}/bin/ls ${mediaMount}";
    Restart = lib.mkDefault "on-failure";
    RestartSec = 15;
  };
}
