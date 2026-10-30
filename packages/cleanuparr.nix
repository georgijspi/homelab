{
  lib,
  buildFHSEnv,
  fetchzip,
  writeShellScript,
}:

let
  version = "2.10.12";
  src = fetchzip {
    url = "https://github.com/Cleanuparr/Cleanuparr/releases/download/v${version}/Cleanuparr-${version}-linux-amd64.zip";
    hash = "sha256-XOb4CNsqxTlceZiDRfClwxVaKo+7aZFdSxhUunix8/8=";
  };
in
buildFHSEnv {
  name = "cleanuparr";

  targetPkgs = pkgs: [
    pkgs.stdenv.cc.cc.lib
    pkgs.icu
    pkgs.openssl
    pkgs.zlib
  ];

  runScript = writeShellScript "cleanuparr-run" ''
    cd ${src}
    exec ./Cleanuparr "$@"
  '';

  meta = {
    description = "Download queue cleaner and malware blocker for the Servarr ecosystem";
    homepage = "https://cleanuparr.github.io/";
    license = lib.licenses.gpl3Only;
    mainProgram = "cleanuparr";
    platforms = [ "x86_64-linux" ];
  };
}
