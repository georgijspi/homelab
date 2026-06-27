{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      intel-compute-runtime-legacy1
    ];
  };

  users.users.jellyfin.extraGroups = [ "video" "render" ];
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";

  environment.systemPackages = with pkgs; [
    libva-utils
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
