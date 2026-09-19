# hypridle ported from anotherhadi/nixy (home/system/hypridle/default.nix).
{ pkgs, ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof ${pkgs.hyprlock}/bin/hyprlock || ${pkgs.hyprlock}/bin/hyprlock --grace 5";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300; # 5 min → lock
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 360; # 6 min → screen off
          on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
        {
          timeout = 1800; # 30 min → suspend
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
