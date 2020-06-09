{ stdenv, lib, fetchurl, autoPatchelfHook
, qtbase
, qtquickcontrols2
, qtdeclarative
}:

stdenv.mkDerivation rec {
  pname = "pia-desktop";
  version = "2.1-04977";

  src = fetchurl {
    url = "https://installers.privateinternetaccess.com/download/pia-linux-${version}.run";
    sha256 = "1s4qgv85k1mzw25hbmixp1b0ihjvm83ixy1h3s15ykjgs8fhx5cy";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    stdenv.cc.cc
    qtbase
    qtquickcontrols2
    qtdeclarative
  ];

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  unpackPhase = /* sh */ ''
    sh $src --target . --noprogress --noexec
  '';

  installPhase = /* sh */ ''
    mkdir -p $out/bin
    cp -r piafiles/{lib,share,bin} $out
    ln -s /opt/piavpn/etc/{account,data,settings}.json $out/etc
    ln -s /opt/piavpn/var $out/var
    rm $out/lib/libQt5*
  '';
}
