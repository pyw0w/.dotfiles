{ lib, stdenv, fetchurl, unzip, makeWrapper, icu, zlib, openssl, libkrb5 }:

let
  version = "6.2.1.2";
in

stdenv.mkDerivation rec {
  pname = "archisteamfarm";
  inherit version;

  src = fetchurl {
    url = "https://github.com/JustArchiNET/ArchiSteamFarm/releases/download/${version}/ASF-linux-x64.zip";
    sha256 = "2U2wcH5poYD+F60M74RDy1B8pz/CRyLfK4x+F3nVvps=";
  };

  nativeBuildInputs = [ unzip makeWrapper ];
  
  # Add required runtime dependencies
  buildInputs = [ icu zlib openssl libkrb5 ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/archisteamfarm
    
    # Copy all files to the share directory
    cp -r * $out/share/archisteamfarm/
    
    # Create a wrapper script that sets up the environment
    makeWrapper $out/share/archisteamfarm/ArchiSteamFarm $out/bin/ArchiSteamFarm \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ icu zlib openssl libkrb5 ]}
    
    ln -s $out/bin/ArchiSteamFarm $out/bin/asf
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "C# application with primary purpose of farming Steam cards";
    homepage = "https://github.com/JustArchiNET/ArchiSteamFarm";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.linux;
    mainProgram = "ArchiSteamFarm";
  };
}
