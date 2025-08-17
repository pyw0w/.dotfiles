{ lib, stdenv, fetchurl, makeWrapper,
  xorg, libGL, libglvnd, mesa, gtk2, freetype, fontconfig,
  glib, pango, cairo, gdk-pixbuf, atk, cups }:
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

    # wrapper that runs bundled launcher (uses bundled JRE with JavaFX)
    mkdir -p $out/bin
    makeWrapper $out/share/develnext/DevelNext $out/bin/develnext \
      --chdir $out/share/develnext \
      --set JAVA_HOME $out/share/develnext/tools/jre \
      --prefix PATH : $out/share/develnext/tools/jre/bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL libglvnd xorg.libX11 xorg.libXext xorg.libXrender xorg.libXrandr xorg.libXi xorg.libXtst xorg.libXcursor xorg.libXinerama xorg.libXdamage xorg.libXfixes xorg.libXcomposite xorg.libXxf86vm xorg.libXdmcp xorg.libXau xorg.libxcb freetype fontconfig gtk2 glib pango cairo gdk-pixbuf atk cups ]} \
      --set LIBGL_DRIVERS_PATH ${mesa.drivers}/lib/dri \
      --set GDK_BACKEND x11 \
      --set _JAVA_AWT_WM_NONREPARENTING 1 \
      --set JDK_JAVA_OPTIONS "-Dglass.platform=x11 -Dprism.order=es2,sw" \
      --set LIBGL_ALWAYS_SOFTWARE 0

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