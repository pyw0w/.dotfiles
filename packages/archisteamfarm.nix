{ lib, stdenv, fetchurl, unzip, dotnetCorePackages, makeWrapper }:

let
  version = "6.2.1.2";
in

stdenv.mkDerivation rec {
  pname = "archisteamfarm";
  inherit version;

  src = fetchurl {
    url = "https://github.com/JustArchiNET/ArchiSteamFarm/releases/download/${version}/ASF-linux-x64.zip";
    sha256 = "1x58v1wxfwbymsxhpmfxbi35kvsznq3724rr07bk7aqvplcbx1qn";
  };

  nativeBuildInputs = [ unzip makeWrapper ];
  buildInputs = [ dotnetCorePackages.runtime_8_0 ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/archisteamfarm
    cp -r * $out/share/archisteamfarm/
    makeWrapper ${dotnetCorePackages.runtime_8_0}/bin/dotnet $out/bin/ArchiSteamFarm \
      --add-flags "$out/share/archisteamfarm/ArchiSteamFarm.dll" \
      --set DOTNET_ROOT ${dotnetCorePackages.runtime_8_0}
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
