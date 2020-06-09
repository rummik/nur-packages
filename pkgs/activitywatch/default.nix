{ stdenv, lib, system, fetchgit, makeWrapper, buildEnv, writeScriptBin
, pkgs
, bash
, git
, python3
, python3Packages
, nodejs
, jq
}:

let

  inherit (python3Packages) fetchPypi buildPythonPackage buildPythonApplication;
  inherit (stdenv.lib) attrValues makeSearchPath makeBinPath;

  takethetime = buildPythonPackage rec {
    pname = "TakeTheTime";
    version = "0.3.1";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "1y9gzqb9l1f2smx8783ccjzjvby5mphshgrfks7s75mml59h9qyv";
    };
  };

  persist-queue = buildPythonPackage rec {
    pname = "persist-queue";
    version = "0.3.5";
    doCheck = false;
    src = fetchPypi {
      inherit pname version;
      sha256 = "1bdz04ybjqczlp3x4wc4jq2dbr6r6zqbxak0l27av82irg91m2wn";
    };
  };

  awWebui = rec {
    nodePackages = import ./aw-webui-deps.nix {
      inherit pkgs nodejs system;
    };

    nodeModules = buildEnv {
      name = "aw-webui-paths";
      paths = attrValues nodePackages;
      pathsToLink = [ "/bin" "/lib/node_modules" ];
    };

    NODE_PATH = makeSearchPath "lib/node_modules" (
      attrValues nodePackages
    );

    PATH = makeSearchPath "lib/node_modules/.bin" (
      attrValues nodePackages
    );
  };

  awClient = rec {
    nodePackages = import ./aw-client-deps.nix {
      inherit pkgs nodejs system;
    };

    nodeModules = buildEnv {
      name = "aw-client-paths";
      paths = attrValues nodePackages;
      pathsToLink = [ "/bin" "/lib/node_modules" ];
    };

    NODE_PATH = makeSearchPath "lib/node_modules" (
      attrValues nodePackages
    );

    PATH = makeSearchPath "lib/node_modules/.bin" (
      attrValues nodePackages
    );
  };

  fakenpm = writeScriptBin "npm" /* sh */ ''
    #!/bin/sh
    case ''${PWD##*/} in
      aw-client-js)
        nodeModules="${awClient.nodeModules}"
        nodePath="${awClient.NODE_PATH}"
        path="${awClient.PATH}"
        ;;
      aw-webui)
        nodeModules="${awWebui.nodeModules}"
        nodePath="${awWebui.NODE_PATH}"
        path="${awWebui.PATH}"
        ;;
    esac

    #export NODE_PATH="$nodePath:$NODE_PATH"
    export PATH="${nodejs}/bin:$PWD/node_modules/.bin:$PATH"

    #echo $nodeModules

    case "$@" in
      "install") ln -s $nodeModules/lib/node_modules node_modules;;
      "run compile") $(jq -r .scripts.compile package.json);;
      "run build") $(jq -r .scripts.build package.json);;
    esac

    exit 0
  '';

in

buildPythonApplication rec {
  pname = "activitywatch";
  version = "0.8.0b9";

  src = fetchgit {
    url = https://github.com/ActivityWatch/activitywatch.git;
    rev = "v${version}";
    sha256 = "1anrsvzm2ap97lx04hxk8wmq9zwbdys4r05s5ds4gqnws45ddagd";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  doCheck = false;

  nativeBuildInputs = [ makeWrapper fakenpm jq ];

  buildInputs = [
    nodejs
    git
    python3
    python3Packages.pip
  ];

  propagatedBuildInputs =
    [ nodejs ] ++

    (with python3Packages; [
      appdirs
      iso8601
      jsonschema
      peewee
      persist-queue
      python-json-logger
      requests
      strict-rfc3339
      takethetime
    ]);

  postPatch = /* sh */ ''
    sed -i -e 's|/usr/bin/env bash|${bash}/bin/bash|' Makefile
    patchShebangs --build "$PWD"
  '';

  buildPhase = /* sh */ ''
    python3 -m venv venv
    source ./venv/bin/activate
    make build
  '';

  installPhase = /* sh */ ''
    mkdir -p $out/{bin,share/activitywatch}
    mv * $out/share/activitywatch
  '';
}
