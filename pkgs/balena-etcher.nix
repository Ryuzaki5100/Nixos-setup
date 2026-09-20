{
  lib,
  appimageTools,
  fetchurl,
  writeShellScriptBin,
  symlinkJoin,
  xhost,
}:

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

  wrapped = appimageTools.wrapType2 rec {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/balenaEtcher.desktop -t $out/share/applications/
      install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/balena-etcher.png \
        -t $out/share/icons/hicolor/256x256/apps/

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
  };

  # Etcher's own elevation logic shells out to a hardcoded /usr/bin/pkexec or
  # /usr/bin/kdesudo, neither of which exists inside the bubblewrap FHS sandbox
  # the AppImage runs in (and setuid can't work there anyway), so it has to run
  # as root. But pkexec drops DISPLAY/XAUTHORITY (they are only kept when the
  # action carries the allow_gui annotation) and always drops WAYLAND_DISPLAY,
  # leaving Electron with no display and crashing with SIGSEGV. So the launcher
  # forwards them as *arguments*, which pkexec passes through untouched, and
  # this root-side script re-exports them before starting Electron via XWayland.
  # --no-sandbox is required because Chromium refuses to start as root.
  rootExec = writeShellScriptBin "balena-etcher-root-exec" ''
    if [ -n "''${1:-}" ]; then export DISPLAY="$1"; fi
    if [ -n "''${2:-}" ]; then export XAUTHORITY="$2"; fi
    shift 2
    exec ${wrapped}/bin/${pname} --no-sandbox "$@"
  '';

  rootLauncher = writeShellScriptBin "balena-etcher-root" ''
    # GNOME's XWayland access control rejects root's connections, so the
    # root-launched Electron gets a blank window ("Authorization required, but
    # no authorization protocol specified"). Grant root access to this display
    # for the session; root can already do anything, so this adds no real risk.
    ${xhost}/bin/xhost +SI:localuser:root >/dev/null 2>&1 || true

    exec pkexec ${rootExec}/bin/balena-etcher-root-exec \
      "''${DISPLAY:-}" "''${XAUTHORITY:-}" "$@"
  '';
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [
    wrapped
    rootLauncher
    rootExec
  ];
  meta = wrapped.meta;
}
