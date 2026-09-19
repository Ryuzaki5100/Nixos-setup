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
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.writeShellScript "tuigreet-launch" ''
        exec ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --time-format '%H:%M  %A %d %B' \
          --sessions /run/current-system/sw/share/wayland-sessions \
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

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

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