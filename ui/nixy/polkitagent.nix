# HyprPolkitAgent ported from anotherhadi/nixy
# (home/system/hyprland/polkitagent.nix).
{ pkgs, ... }:
{
  home.packages = with pkgs; [ hyprpolkitagent ];

  wayland.windowManager.hyprland.settings.exec-once = [ "systemctl --user start hyprpolkitagent" ];
}
