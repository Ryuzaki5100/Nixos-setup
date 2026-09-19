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

  # TUI login manager (greetd + tuigreet), styled after nixy.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.writeShellScript "tuigreet-launch" ''
          exec ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --time-format '%H:%M  %A %d %B' \
            --sessions /run/current-system/sw/share/wayland-sessions \
            --remember \
            --remember-user-session \
            --asterisks \
            --greeting 'heinz' \
            '--theme' 'border=#cba6f7;text=#cdd6f4;prompt=#cba6f7;action=#94e2d5;button=#cba6f7;container=#1e1e2e;input=#313244' \
            --power-shutdown 'systemctl poweroff' \
            --power-reboot 'systemctl reboot'
        ''}";
        user = "greeter";
      };
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

  # Fonts: JetBrains Mono Nerd Font (UI glyphs) + Inter (UI text).
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
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

  home-manager.users.${variables.username}.imports = [
    ./home.nix
  ];
}