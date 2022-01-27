{ stdenv, lib, autoPatchelfHook, dpkg, zlib }:
let

  src = ./kolide_launcher.deb;

in stdenv.mkDerivation {
  name = "kolide-launcher";

  system = "x86_64-linux";

  inherit src;
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
  ];

  installPhase = ''
    mkdir -p $out
    cp -ar deb/* $out/
    sed -i "s#enroll_secret_path #enroll_secret_path $out#" $out/etc/kolide-k2/launcher.flags
    sed -i "s#osqueryd_path #osqueryd_path $out#" $out/etc/kolide-k2/launcher.flags
    sed -i "#autoupdate#d" $out/etc/kolide-k2/launcher.flags
  '';

  meta = with lib; {
    description = "Kolide Launcher";
    homepage = https://www.kolide.com/launcher/;
    license = licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
