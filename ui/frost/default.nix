# Frost-style UI variant — Hyprland + waybar + rofi + swaync + nvim + ghostty + zsh.
# Curated adaptation of Frost-Phoenix/nixos-config adapted to this Intel desktop.
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

  # TUI login manager (greetd + tuigreet), themed to the frost (gruvbox) palette.
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
          --greeting 'frost' \
          --theme 'border=#FE8019;text=#EBDBB2;prompt=#FE8019;action=#B8BB26;button=#B8BB26;container=#1D2021;input=#282828' \
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