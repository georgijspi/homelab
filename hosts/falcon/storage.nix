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
      # Media downloads must never be executable, even if a malicious release
      # disguises a program as an episode or movie.
      "noexec"
    ];
  };
}
