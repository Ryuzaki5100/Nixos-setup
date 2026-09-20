# Heinz-style UI variant — Hyprland + kitty/alacritty + rofi + dunst + waybar + zsh.
# Curated adaptation of HeinzDev/Hyprland-dotfiles adapted to this Intel desktop.
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

  # TUI login manager (greetd + tuigreet), themed to the heinz palette.
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
          --greeting 'heinz' \
          --theme 'border=#33ccff;text=#F4F4F9;prompt=#33ccff;action=#00ff99;button=#33ccff;container=#1E1F29;input=#282A36' \
          --power-shutdown 'systemctl poweroff' \
          --power-reboot 'systemctl reboot'
      ''}";
      user = "greeter";
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  # Fonts: JetBrains Mono Nerd Font (UI glyphs) + Hack (alacritty) + Inter.
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.hack
    pkgs.inter
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