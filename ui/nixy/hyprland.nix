# Hyprland config ported from anotherhadi/nixy (home/system/hyprland/
# {default.nix,animations.nix}). stylix colours / config.theme are replaced by
# the local theme data; everything else is kept upstream.
{ pkgs, lib, ... }:
let
  t = import ./theme.nix;
  c = t.colors;
  background = "rgba(${c.base00}EE)";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    xwayland.enable = true;
    settings = {
      monitor = [ ",preferred,auto,1" ];

      exec-once = [
        "systemctl --user start app-com.mitchellh.ghostty.service"
      ];

      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "ANKI_WAYLAND,1"
        "DISABLE_QT5_COMPAT,0"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_QPA_PLATFORMTHEME,gtk3"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "DIRENV_LOG_FORMAT,"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
      ];

      cursor.no_hardware_cursors = true;

      general = {
        resize_on_border = true;
        gaps_in = t.gapsIn;
        gaps_out = t.gapsOut;
        border_size = t.borderSize;
        layout = "master";
        "col.inactive_border" = lib.mkForce background;
      };

      decoration = {
        active_opacity = t.activeOpacity;
        inactive_opacity = t.inactiveOpacity;
        rounding = t.rounding;
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
        };
        blur = {
          enabled = if t.blur then "true" else "false";
          size = 18;
        };
      };

      master = {
        new_status = "slave";
        allow_small_split = true;
        mfact = 0.5;
      };

      gesture = "3, horizontal, workspace";

      layerrule = [
        "match:namespace launcher, animation popin 70%"
        "match:namespace swaync-control-center, animation slide right"
      ];

      windowrule = [
        "match:class .*, suppress_event maximize"
        "match:class helium, suppress_event fullscreen"
        "match:class helium, sync_fullscreen false"

        "match:class ^(steam_app_.*)$, suppress_event fullscreen"
        "match:class ^(steam_app_.*)$, sync_fullscreen false"

        "match:class proton-authenticator, float on"
        "match:class proton-authenticator, center on"
        "match:class proton-authenticator, size 500 400"

        "match:class protonvpn-app, float on"
        "match:class protonvpn-app, center on"
        "match:class protonvpn-app, size 500 400"

        "match:title run-bg, float on"
        "match:title run-bg, center on"
        "match:title run-bg, size 700 80"

        "match:workspace special:scratch, opacity 1 1"
        "match:workspace special:scratch, no_anim on"
      ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        disable_autoreload = true;
        focus_on_activate = true;
      };

      input = {
        kb_layout = "us";
        kb_options = "caps:escape";
        follow_mouse = 1;
        sensitivity = 0.5;
        repeat_delay = 300;
        repeat_rate = 50;
        numlock_by_default = true;
        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
        };
      };

      ecosystem.no_update_news = true;

      # ── animations (home/system/hyprland/animations.nix) ──────────────────
      animations = {
        enabled = true;
        bezier = [
          "linear, 0, 0, 1, 1"
          "md3_standard, 0.2, 0, 0, 1"
          "md3_decel, 0.05, 0.7, 0.1, 1"
          "md3_accel, 0.3, 0, 0.8, 0.15"
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "crazyshot, 0.1, 1.5, 0.76, 0.92"
          "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.38, 0.04, 1, 0.07"
          "easeInOutCirc, 0.85, 0, 0.15, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
          "softAcDecel, 0.26, 0.26, 0.15, 1"
          "md2, 0.4, 0, 0.2, 1"
        ];
        animation = [
          "windows, 1, ${t.animationDuration}, md3_decel, popin 60%"
          "windowsIn, 1, ${t.animationDuration}, md3_decel, popin 60%"
          "windowsOut, 1, ${t.animationDuration}, md3_accel, popin 60%"
          "border, 1, ${t.animationDuration}, default"
          "fade, 1, ${t.animationDuration}, md3_decel"
          "layersIn, 1, ${t.animationDuration}, menu_decel, slide"
          "layersOut, 1, ${t.animationDuration}, menu_accel"
          "fadeLayersIn, 1, ${t.animationDuration}, menu_decel"
          "fadeLayersOut, 1, ${t.animationDuration}, menu_accel"
          "workspaces, 1, ${t.animationDuration}, menu_decel, slide"
          "specialWorkspace, 0, ${t.animationDuration}, md3_decel, slidevert"
        ];
      };
    };
  };

  qt.enable = true;

  home.sessionVariables = {
    XDG_ICON_DIR = "${pkgs.papirus-icon-theme}/share/icons/Papirus";
    QS_ICON_THEME = "Papirus";
    QT_STYLE_OVERRIDE = lib.mkForce "Fusion";
  };
}
