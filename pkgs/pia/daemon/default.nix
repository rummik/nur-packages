{ stdenv, lib, fetchurl, autoPatchelfHook
, qtbase
, qtquickcontrols2
, qtdeclarative
}:

stdenv.mkDerivation rec {
  pname = "pia-daemon";
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
  ];

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  unpackPhase = /* sh */ ''
    sh $src --target . --noprogress --noexec
  '';

  installPhase = /* sh */ ''
    mkdir -p $out
    cp -r piafiles/{bin,lib,etc,share} $out
    rm $out/lib/libQt5*
  '';

  #installCheckPhase = /* sh */ ''
    #cp -r piafiles/{plugins,qml} $out
  #'';
}

