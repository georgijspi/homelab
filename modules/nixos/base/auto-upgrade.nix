{ config, ... }:

{
  system.autoUpgrade = {
    enable = true;
    flake = "path:/etc/nixos#falcon";
    flags = [
      "--impure"
    ];
    allowReboot = false;
    dates = "04:00";
    randomizedDelaySec = "45min";
    runGarbageCollection = true;
  };

  systemd.services.nixos-upgrade.preStart = ''
    ${config.nix.package}/bin/nix flake update --flake /etc/nixos
  '';

  nix.gc = {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "45min";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = "weekly";
    randomizedDelaySec = "45min";
  };
}
