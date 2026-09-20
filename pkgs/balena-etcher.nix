{ lib, appimageTools, fetchurl, runtimeShell }:

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

    # Etcher's own elevation logic shells out to a hardcoded /usr/bin/pkexec
    # or /usr/bin/kdesudo, neither of which exists inside the bubblewrap FHS
    # sandbox this AppImage runs in (and setuid cannot work there anyway).
    # Launch the sandboxed app as root via the host's pkexec so Etcher sees
    # euid 0 and skips elevation entirely; --no-sandbox is required because
    # Chromium refuses to start as root otherwise.
    cat > $out/bin/balena-etcher-root <<EOF
    #!${runtimeShell}
    exec pkexec $out/bin/balena-etcher --no-sandbox "\$@"
    EOF
    chmod +x $out/bin/balena-etcher-root

    substituteInPlace $out/share/applications/balenaEtcher.desktop \
      --replace-fail 'Exec=balena-etcher %U' 'Exec=balena-etcher-root %U'
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
