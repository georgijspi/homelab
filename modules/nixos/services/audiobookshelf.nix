{ lib, pkgs, utils, vars, ... }:

let
  mediaMount = vars.storage.nasMediaMount;
in
{
  services.audiobookshelf = {
    enable = true;
    host = vars.services.audiobookshelf.host;
    port = vars.services.audiobookshelf.port;
  };

  systemd.services.audiobookshelf =
    import ../lib/nas-dependent.nix { inherit lib pkgs utils vars; };

  systemd.tmpfiles.rules = [
    "d ${mediaMount}/audiobookshelf 0775 audiobookshelf audiobookshelf -"
    "d ${mediaMount}/audiobookshelf/audiobooks 0775 audiobookshelf audiobookshelf -"
    "d ${mediaMount}/audiobookshelf/podcasts 0775 audiobookshelf audiobookshelf -"
    "d ${mediaMount}/audiobookshelf/books 0775 audiobookshelf audiobookshelf -"
    "d ${mediaMount}/audiobookshelf/manga 0775 audiobookshelf audiobookshelf -"
  ];
}
