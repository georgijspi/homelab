{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jellyfin-ffmpeg
    intel-gpu-tools
    ghostty.terminfo
    sops
  ];
}
