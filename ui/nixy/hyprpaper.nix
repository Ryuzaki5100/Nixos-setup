# hyprpaper ported from anotherhadi/nixy (home/system/hyprland/hyprpaper.nix).
{ pkgs, lib, ... }:
let
  wallpapers = import ../shared/wallpapers.nix { inherit pkgs lib; };
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      preload = [ "${wallpapers.nixy}" ];
      wallpaper = [ ",${wallpapers.nixy}" ];
    };
  };
  systemd.user.services.hyprpaper.Unit.After = lib.mkForce "graphical-session.target";

  wayland.windowManager.hyprland.settings.exec-once = [
    "systemctl --user enable --now hyprpaper.service"
  ];
}
