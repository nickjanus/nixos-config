{ pkgs, stdenv, lib, autoPatchelfHook, dpkg, zlib, libelf, parameters }:
let
  sentinelone = stdenv.mkDerivation {
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

      cat << CONFIG > $out/opt/sentinelone/configuration/install_config
      S1_AGENT_MANAGEMENT_TOKEN=${parameters.sentinelone_token}
      CONFIG

      cat << CONFIG > $out/opt/sentinelone/configuration/local.conf
      {
          "mgmt_device-type": 0
      }
      CONFIG
    '';

    meta = with lib; {
      description = "sentinelone-base";
      homepage = https://www.sentinelone.com/;
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
in stdenv.mkDerivation {
  name = "sentinelone";
  system = "x86_64-linux";
  phases       = [ "installPhase" ];
  buildInputs  = with pkgs; [ makeWrapper ];
  installPhase = ''
    mkdir -p $out
    cp -ar ${sentinelone}/* $out/
    chmod -R 766 $out/opt

    makeWrapper ${sentinelone}/opt/sentinelone/bin/sentinelctl $out/opt/sentinelone/bin/sentinelctl \
      --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "/opt/sentinelone=/${sentinelone}/opt/sentinelone"
    makeWrapper ${sentinelone}/opt/sentinelone/bin/sentinelone-agent $out/opt/sentinelone/bin/sentinelone-agent \
      --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "/opt/sentinelone=/${sentinelone}/opt/sentinelone"
    makeWrapper ${sentinelone}/opt/sentinelone/bin/sentinelone-watchdog $out/opt/sentinelone/bin/sentinelone-watchdog \
      --set LD_PRELOAD    "${pkgs.libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS "/opt/sentinelone=/${sentinelone}/opt/sentinelone"
  '';
}
