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
