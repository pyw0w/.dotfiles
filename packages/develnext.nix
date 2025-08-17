{ lib, stdenv, fetchurl, makeWrapper,
  xorg, libGL, libglvnd, mesa, gtk2, freetype, fontconfig,
  glib, pango, cairo, gdk-pixbuf, atk, cups, imagemagick }:
stdenv.mkDerivation rec {
  pname = "develnext";
  version = "16.7.0";

  # Linux distributive linked from GitHub Releases (v16.7.0)
  src = fetchurl {
    url = "https://cdn.develnext.org/files/DevelNextLinux-16.7.0-Autumn.tar.gz";
    hash = "sha256-mLVvZRpHVs4/PlhRS8mZZW/i8TttOQmrRYYEEfgL3yk=";
    name = "develnext-${version}.tar.gz";
  };

  nativeBuildInputs = [ makeWrapper imagemagick ];

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

    # install icon and desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/develnext.desktop <<EOF
[Desktop Entry]
Name=DevelNext
Comment=GUI IDE for JPHP
Exec=develnext %F
Terminal=false
Type=Application
Categories=Development;IDE;
Icon=develnext
StartupNotify=true
EOF

    # Preferred: use original ICO from distribution to generate hicolor icons
    ICO="$out/share/develnext/projectExtension.ico"
    if [ -f "$ICO" ]; then
      for size in 256 128 64 48 32 16; do
        mkdir -p "$out/share/icons/hicolor/"$size"x"$size"/apps"
        ${imagemagick}/bin/convert "$ICO" -alpha on -background none -resize "$size"x"$size" "$out/share/icons/hicolor/"$size"x"$size"/apps/develnext.png"
      done
      # pixmaps symlink to common 128px
      mkdir -p $out/share/pixmaps
      ln -s $out/share/icons/hicolor/128x128/apps/develnext.png $out/share/pixmaps/develnext.png
    else
      # Fallback: use bundled language icon if ICO is missing
      mkdir -p $out/share/icons/hicolor/128x128/apps
      mkdir -p $out/share/pixmaps
      if [ -f $out/share/develnext/languages/en/icon.png ]; then
        cp $out/share/develnext/languages/en/icon.png $out/share/icons/hicolor/128x128/apps/develnext.png
        ln -s $out/share/icons/hicolor/128x128/apps/develnext.png $out/share/pixmaps/develnext.png
      fi
    fi

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