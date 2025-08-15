final: prev: {
  technorino = prev.chatterino7.overrideAttrs (oldAttrs: {
    pname = "technorino";
    version = "nightly";

    buildInputs =
      oldAttrs.buildInputs
      ++ (with prev; [
        kdePackages.qtimageformats
        libnotify
      ]);
    src = final.chatterino7.src.override {
      owner = "2547techno";
      repo = "technorino";
      tag = null;
      rev = "ca72ecfcc8db40c16051adf7c426a01eaffd5c6c";
      hash = "sha256-pG96nAyjEtfeOCkhG5rTs1g3Vq4lXHpLSDq0Tr196wQ=";
    };
  });
}
