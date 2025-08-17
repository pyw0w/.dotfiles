{ lib, stdenv, fetchurl, makeWrapper, jdk8 }:
stdenv.mkDerivation rec {
  pname = "develnext";
  version = "16.7.0";

  # Linux distributive linked from GitHub Releases (v16.7.0)
  src = fetchurl {
    url = "https://cdn.develnext.org/files/DevelNextLinux-16.7.0-Autumn.tar.gz";
    hash = "sha256-mLVvZRpHVs4/PlhRS8mZZW/i8TttOQmrRYYEEfgL3yk=";
    name = "develnext-${version}.tar.gz";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/develnext
    # extract archive directly into share dir (archive contains multiple top-level entries)
    tar -xzf "$src" -C $out/share/develnext

    mkdir -p $out/bin
    makeWrapper ${jdk8}/bin/java $out/bin/develnext \
      --chdir $out/share/develnext \
      --add-flags "-jar $out/share/develnext/DevelNext.jar"

    runHook postInstall
  '';

  meta = {
    description = "DevelNext IDE (Linux distributive from GitHub release v16.7.0)";
    homepage = "https://github.com/jphp-group/develnext";
    license = lib.licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "develnext";
  };
} 