{ pkgs, vars, ... }:

let
  storage = vars.storage;
in
{
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  fileSystems.${storage.nasMediaMount} = {
    device = "${storage.nasAddress}:${storage.nasExport}";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
    ];
  };
}
