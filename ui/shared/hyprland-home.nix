# Shared Home-Manager userland common to the three Hyprland variants.
# Only truly common Wayland tooling lives here; all visual/UI config
# (hyprland.conf, waybar, launcher, terminal, notifications, lockscreen,
# wallpaper daemon) is defined per-variant in ui/<variant>/rice.nix.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
{
  # ── Common Wayland user packages ─────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland tooling
    wl-clipboard
    wayland-utils
    libnotify
    dconf
    grim
    slurp
    satty
    wf-recorder
    hyprpicker
    cliphist

    # Audio / brightness / media
    pamixer
    playerctl
    brightnessctl
    pavucontrol
    wireplumber
    mate-polkit

    # Idle / lock / hydrate
    hypridle
    hyprlock

    # GTK theming
    papirus-icon-theme
    adw-gtk3
    gnome-themes-extra
  ];

  # ── Session / Wayland environment ────────────────────────────────────────
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    COLORTERM = "truecolor";
  };
}