# Apps shared across every UI variant: Steam (full gaming defaults),
# Zen Browser (+ Firefox), and OpenGL/compositor plumbing.
{
  pkgs,
  lib,
  zen-browser,
  ...
}:

{
  # Hardware acceleration (Intel iGPU) — needed for Steam, games, and
  # Wayland compositors.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Steam with the full gaming defaults.
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Browsers: Zen Browser (flake-pinned beta) + Firefox (stock).
  programs.firefox.enable = true;

  environment.systemPackages = [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}