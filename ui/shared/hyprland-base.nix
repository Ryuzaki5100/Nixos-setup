# Shared NixOS-level module for Hyprland-based UI variants.
# Usage: import ../shared/hyprland-base.nix { greetText = "…"; accent = "#…"; }
{
  greetText,
  accent ? "#89b4fa",
}:
{
  pkgs,
  lib,
  variables,
  ...
}:
{
  # ── Hyprland compositor ─────────────────────────────────────────────────
  programs.hyprland.enable = true;
  environment.systemPackages = [ pkgs.hyprland ];

  # Wayland hints for Electron/Chromium/Firefox.
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # Fonts shared by all Hyprland variants.
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.inter
  ];

  # PAM for Hyprlock.
  security.pam.services.hyprlock = { };

  # ── greetd + tuigreet (TUI login manager) ───────────────────────────────
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''
        ${pkgs.writeShellScript "gt-launch" ''
          exec ${pkgs.tuigreet}/bin/tuigreet \
            --greeting '${greetText}' \
            --time \
            --time-format '%H:%M  %A %d %B' \
            --sessions /run/current-system/sw/share/wayland-sessions \
            --remember \
            --remember-user-session \
            --asterisks \
            --power-shutdown 'systemctl poweroff' \
            --power-reboot 'systemctl reboot' \
            --theme 'border=${accent};text=#cdd6f4;prompt=${accent};action=#94e2d5;button=${accent};container=#1e1e2e;input=#313244'
        ''}
      '';
      user = "greeter";
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # ── XDG desktop portals (hyprland + gtk) ────────────────────────────────
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
