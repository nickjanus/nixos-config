{ stdenv, autoPatchelfHook, dpkg, zlib, libelf }:
let
  src = ./SentinelAgent_linux_v21_6_2_5.deb;
  version = "v21_6_2_5";
in stdenv.mkDerivation {
  inherit src; 
  name = "SentinelOne-${version}";
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
  '';

  meta = with stdenv.lib; {
    description = "sentinelone";
    homepage = https://www.sentinelone.com/;
    license = licenses.unfree;
    maintainers = with stdenv.lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
