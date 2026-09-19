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

  # ── Activation cleanup ───────────────────────────────────────────────────
  # Hyprland 0.55 auto-generates a plain-file `hyprland.conf` STUB when it
  # starts without a usable config (e.g. first boot before HM files activate).
  # That stale stub would shadow the HM-managed hyprland.conf, so remove it on
  # each switch — but only if it is a real file. Never delete the symlink HM
  # manages, or the rice config would vanish on every activation.
  home.activation.removeHyprlandStub = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "$HOME/.config/hypr/hyprland.conf" ] && [ ! -L "$HOME/.config/hypr/hyprland.conf" ]; then
      rm -f "$HOME/.config/hypr/hyprland.conf"
    fi
    rm -f "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/.luarc.json"
  '';
}