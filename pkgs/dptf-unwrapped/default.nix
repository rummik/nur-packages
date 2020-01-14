{ stdenv, buildFHSUserEnv, fetchFromGitHub,
  cmake,
  readline6,
}:

stdenv.mkDerivation rec {
  pname = "dptf-unwrapped";
  version = "8.7.10100";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "dptf";
    rev = version;
    sha256 = "1s143837vym0q3rajw62s7xjv82b2j5kqr5pj6brhr31s7c5nzz8";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ readline6 ];

  enableParallelBuilding = true;

  dontConfigure = true;

  CXXFLAGS = [
    "-Wno-catch-value"
    "-Wno-stringop-truncation"
  ];

  CFLAGS = [
    "-Wno-format-truncation"
    "-Wno-error=stringop-overflow"
  ];

  buildPhase = /* sh */ ''
    pushd DPTF/Linux/build
    cmake ..
    make -j$NIX_BUILD_CORES
    popd

    pushd ESIF/Products/ESIF_UF/Linux
    make -j$NIX_BUILD_CORES
    popd

    pushd ESIF/Products/ESIF_CMP/Linux
    make -j$NIX_BUILD_CORES
    popd

    pushd ESIF/Products/ESIF_WS/Linux
    make -j$NIX_BUILD_CORES
    popd
  '';

  installPhase = /* sh */ ''
    mkdir -p $out/share/dptf/ufx64

    for so in DPTF/Linux/build/x64/release/Dptf*.so; do
      cp $so $out/share/dptf/ufx64
      cp $so $out/share/dptf/ufx64/$(basename ''${so,,})
    done

    cp ESIF/Products/ESIF_CMP/Linux/esif_cmp.so $out/share/dptf/ufx64
    cp ESIF/Products/ESIF_WS/Linux/esif_ws.so $out/share/dptf/ufx64

    mkdir -p $out/etc/dptf
    cp ESIF/Packages/DSP/dsp.dv $out/etc/dptf

    mkdir -p $out/bin
    cp ESIF/Products/ESIF_UF/Linux/esif_ufd $out/bin

    mkdir -p $out/share/licenses/dptf
    cp LICENSE.txt $out/share/licenses/dptf
  '';

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/dptf/;
    description = "Intel Dynamic Platform and Tuning Framework";
    platforms = platforms.linux;
    license = with licenses; [ apsl20 [ bsd3 gpl2 ] ];
    maintainers = with maintainers; [ rummik ];
  };
}
