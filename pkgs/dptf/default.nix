{ stdenv, buildFHSUserEnv,
  dptf-unwrapped,
}:

buildFHSUserEnv {
  name = "esif_ufd";

  targetPkgs = pkgs: [
    dptf-unwrapped
  ];

  runScript = "esif_ufd";

  passthru = {
    inherit (dptf-unwrapped) pname version meta;
  };
}
