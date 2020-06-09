{ stdenv, fetchFromGitHub, fetchNuGet,
  buildDotnetPackage,
  dotnetPackages,
	mono,
}:

buildDotnetPackage rec {
  baseName = "nbfc";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "hirschmann";
    repo = "nbfc";
    rev = version;
    sha256 = "0m11z5wvm5mpixc0mnh827m8ayfkjbg25qpf5y3k1nns14avz9mk";
  };

  buildInputs = [
    (fetchNuGet rec {
      baseName = "NLog";
      version = "4.0.0.0";
      sha256 = "14i08pfhhikmywkvpc71mgyvn6i6q5hvq4acf61r534q5wmxs14c";
      outputFiles = [ "lib/net45/*" ];
    })

    (fetchNuGet rec {
      baseName = "FakeItEasy";
      version = "4.0.0.0";
      sha256 = "1k65sqsrp658l4bfrpwkhjjb6rlivgz6aaniaydvski9pdq943c7";
      outputFiles = [ "lib/net45/*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.core";
      version = "2.4.1";
      sha256 = "1nnb3j4kzmycaw1g76ii4rfqkvg6l8gqh18falwp8g28h802019a";
      outputFiles = [ "*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.core";
      version = "2.4.1.0";
      sha256 = "1nnb3j4kzmycaw1g76ii4rfqkvg6l8gqh18falwp8g28h802019a";
      outputFiles = [ "*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.extensibility.core";
      version = "2.4.1";
      sha256 = "103qsijmnip2pnbhciqyk2jyhdm6snindg5z2s57kqf5pcx9a050";
      outputFiles = [ "lib/*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.extensibility.execution";
      version = "2.4.1";
      sha256 = "1pbilxh1gp2ywm5idfl0klhl4gb16j86ib4x83p8raql1dv88qia";
      outputFiles = [ "lib/*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.assert";
      version = "2.4.1.0";
      sha256 = "1imynzh80wxq2rp9sc4gxs4x1nriil88f72ilhj5q0m44qqmqpc6";
      outputFiles = [ "lib/netstandard1.1/*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.abstractions";
      version = "2.0.0.0";
      sha256 = "0a5gc58j4syg7i3zpql37phd6m9z58y5i991hwcn7jljw0a3zknz";
      outputFiles = [ "lib/net35/*" ];
    })

    (fetchNuGet rec {
      baseName = "xunit.runner.visualstudio";
      version = "2.4.1";
      sha256 = "0fln5pk18z98gp0zfshy1p9h6r9wc55nyqhap34k89yran646vhn";
      outputFiles = [ "*" ];
    })

    (fetchNuGet rec {
      baseName = "clipr";
      version = "1.6.0.1";
      sha256 = "1hfadj8kfwq5j7703paxrphilxbzpm9szn71n9z6mywjrkigybjr";
      outputFiles = [ "lib/net35/*" ];
    })

    (fetchNuGet rec {
      baseName = "System.IO.Abstractions";
      version = "2.1.0.256";
      sha256 = "1300yb07lxpwly7pna2mb7lkssm3j86cbhifm9y9haxps5kydbjh";
      outputFiles = [ "lib/net40/*" ];
    })

    (fetchNuGet rec {
      baseName = "System.IO.Abstractions.TestingHelpers";
      version = "2.1.0.256";
      sha256 = "147micrkh7kbnsrxy44rxd48p1zwfsi14rdnnrbpc8ld9wrhihnj";
      outputFiles = [ "lib/net40/*" ];
    })
  ];

  preBuild =
    let link = input: /* sh */ ''
      mkdir -p packages/${input.baseName}.${input.version}

      ln -sn ${input}/lib/dotnet/${input.baseName}/ \
        packages/${input.baseName}.${input.version}/lib

      ln -sn ${input}/lib/dotnet/${input.baseName}/* \
				packages/${input.baseName}.${input.version} || true
    '';
    in (map link buildInputs) ++ [ /* sh */ ''
      mkdir -p Core/NbfcCli/bin/ReleaseLinux
      cp packages/clipr.1.6.0.1/clipr.dll Core/NbfcCli/bin/ReleaseLinux
    '' ];

  preInstall = /* sh */ ''
    #cp packages/**/*.dll Linux/bin/Release
  '';

  xBuildFiles = [ "NoteBookFanControl.sln" ];
  xBuildFlags = [ "/t:Build" "/p:Configuration=ReleaseLinux" ];

  outputFiles = [ "Linux/bin/Release/*" "Config/*" ];
  dllFiles = [ "**/*.dll" ];

  meta = with stdenv.lib; {
    homepage = https://github.com/intel/dptf/;
    description = "Intel Dynamic Platform and Tuning Framework";
    platforms = platforms.linux;
    license = with licenses; [ apsl20 [ bsd3 gpl2 ] ];
    maintainers = with maintainers; [ rummik ];
  };
}
