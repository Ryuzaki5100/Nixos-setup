# Nixy-style UI variant — Hyprland + waybar + tofi + ghostty + zsh + swaync.
# Curated adaptation of anotherhadi/nixy adapted to this Intel desktop.
{
  pkgs,
  lib,
  variables,
  ...
}:
{
  # Hyprland Wayland compositor.
  programs.hyprland.enable = true;

  # Wayland hints for Electron/Chromium and Firefox.
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # PAM for hyprlock.
  security.pam.services.hyprlock = { };

  # TUI login manager (greetd + tuigreet), themed to the nixy palette.
  # useTextGreeter sets TTYPath=/dev/tty1 (+ tty options) which greetd needs to
  # run a TUI greeter; --cmd launches Hyprland against the Home-Manager rice.
  services.displayManager.defaultSession = "hyprland";
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session = {
      command = "${pkgs.writeShellScript "tuigreet-launch" ''
        exec ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --time-format '%H:%M  %A %d %B' \
          --cmd '${pkgs.hyprland}/bin/Hyprland --config /home/${variables.username}/.config/hypr/hyprland.conf' \
          --remember \
          --remember-user-session \
          --asterisks \
          --container-padding 2 \
          --greeting 'Welcome' \
          --theme 'border=#9E97F8;text=#C2BED6;prompt=#9E97F8;action=#70B8C0;button=#9E97F8;container=#0A0A0C;input=#2D2A36' \
          --power-shutdown 'systemctl poweroff' \
          --power-reboot 'systemctl reboot'
      ''}";
      user = "greeter";
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  # Fonts: Maple Mono NF (UI/terminal glyphs) + Rubik (UI text) + emoji.
  fonts.packages = [
    pkgs.maple-mono.NF
    pkgs.rubik
    pkgs.noto-fonts-color-emoji
  ];

  # XDG desktop portals (hyprland + gtk fallback).
  xdg.portal = {
    enable = true;
    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}