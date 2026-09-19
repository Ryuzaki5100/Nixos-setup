# exec-once ported from Frost-Phoenix/nixos-config
# (modules/home/hyprland/exec-once.nix). The laptop-only monitor-watcher line
# is dropped (this host is a desktop).
{ ... }:
{
  wayland.windowManager.hyprland.settings.exec-once = [
    "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

    "hyprlock"

    "nm-applet &"
    "poweralertd &"
    "wl-clip-persist --clipboard both &"
    "wl-paste --watch cliphist store &"
    "waybar &"
    "swaync &"
    "udiskie --automount --notify --smart-tray &"
    "hyprctl setcursor Bibata-Modern-Ice 24 &"
    "init-wallpaper &"

    "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
    "[workspace 1 silent] zen-beta"
    "[workspace 2 silent] ghostty"
  ];
}
