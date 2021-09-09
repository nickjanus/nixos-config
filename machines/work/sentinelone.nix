{ pkgs, stdenv, lib, autoPatchelfHook, dpkg, zlib, libelf }:
stdenv.mkDerivation {
  src = ./SentinelAgent_linux_v21_6_2_5.deb;
  name = "SentinelOne-v21_6_2_5";
  system = "x86_64-linux";

  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x $src deb/";

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];
  buildInputs = [
    zlib
    libelf
  ];

  installPhase = ''
    mkdir -p $out
    cp -ar deb/* $out/
    # put these in bin so this derivation gets linked to current system
    cp -ar $out/opt/sentinelone/bin $out/bin
  '';

  meta = with lib; {
    description = "sentinelone";
    homepage = https://www.sentinelone.com/;
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
