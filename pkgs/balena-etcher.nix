{ lib, appimageTools, fetchurl }:

let
  pname = "balena-etcher";
  version = "2.1.3";

  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-x64.AppImage";
    hash = "sha256-0Xl2rCALA3mxZoskpR6/aRJIVdfb8o8TM8RGRZuUFH8=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/balenaEtcher.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/balena-etcher.png \
      -t $out/share/icons/hicolor/256x256/apps/

    substituteInPlace $out/share/applications/balenaEtcher.desktop \
      --replace-fail 'Exec=balena-etcher %U' 'Exec=${meta.mainProgram} %U'
  '';

  meta = {
    description = "Flash OS images to SD cards and USB drives, safely and easily";
    homepage = "https://etcher.balena.io";
    downloadPage = "https://github.com/balena-io/etcher/releases";
    changelog = "https://github.com/balena-io/etcher/releases/tag/v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
