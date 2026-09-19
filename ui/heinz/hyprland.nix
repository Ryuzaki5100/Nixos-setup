# Hyprland config ported from HeinzDev/Hyprland-dotfiles
# (home/programs/hypr/{default.nix,hyprland-environment.nix}), translated to
# Hyprland 0.55 hyprlang. NVIDIA-only env vars from upstream are dropped since
# this host is Intel; the rest is kept verbatim in intent.
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    waybar
    awww
  ];

  home.sessionVariables = {
    BROWSER = "librewolf";
    TERMINAL = "kitty";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
    "$mainMod" = "SUPER";

    monitor = [ ",preferred,auto,1" ];

    # Fix slow startup + (re)start the bar (upstream uses bare `exec`).
    exec = [
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "pkill waybar & sleep 0.5 && waybar"
    ];

    # Autostart
    exec-once = [
      "hyprctl setcursor Bibata-Modern-Classic 24"
      "dunst"
      "awww-daemon & sleep 0.5 && exec wallpaper_random"
    ];

    source = "${config.home.homeDirectory}/.config/hypr/colors";

    # Input config
    input = {
      kb_layout = "br,us";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
      kb_rules = "";
      follow_mouse = 1;
      sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      touchpad.natural_scroll = false;
    };

    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
    };

    decoration = {
      rounding = 10;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
      };
      shadow = {
        enabled = true;
        range = 4;
        render_power = 3;
        color = "rgba(1a1a1aee)";
      };
    };

    animations = {
      enabled = true;
      bezier = "ease,0.4,0.02,0.21,1";
      animation = [
        "windows, 1, 3.5, ease, slide"
        "windowsOut, 1, 3.5, ease, slide"
        "border, 1, 6, default"
        "fade, 1, 3, ease"
        "workspaces, 1, 3.5, ease"
      ];
    };

    dwindle = {
      preserve_split = true;
    };

    master = {
      new_status = "master";
    };

    # windowrules (upstream v1 rules translated to 0.55 match: syntax)
    windowrule = [
      "match:class ^(kitty)$, float on"
      "match:class ^(pavucontrol)$, float on"
      "match:class ^(kitty)$, center on"
      "match:class ^(blueman-manager)$, float on"
      "match:class ^(kitty)$, size 600 500"
      "match:class ^(mpv)$, size 934 525"
      "match:class ^(mpv)$, float on"
      "match:class ^(mpv)$, center on"
    ];

    bind =
      [
        "$mainMod, G, fullscreen,"

        "$mainMod, RETURN, exec, kitty"
        "$mainMod, B, exec, opera --no-sandbox"
        "$mainMod, L, exec, firefox"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, F, exec, nautilus"
        "$mainMod, V, togglefloating,"
        "$mainMod, w, exec, wofi --show drun"
        "$mainMod, R, exec, rofiWindow"
        "$mainMod, P, pseudo," # dwindle
        "$mainMod, J, togglesplit," # dwindle

        # Switch Keyboard Layouts
        "$mainMod, SPACE, exec, hyprctl switchxkblayout teclado-gamer-husky-blizzard next"

        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "SHIFT, Print, exec, grim -g \"$(slurp)\""

        # Functional keybinds
        ", XF86AudioMicMute, exec, pamixer --default-source -t"
        ", XF86MonBrightnessDown, exec, light -U 20"
        ", XF86MonBrightnessUp, exec, light -A 20"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioLowerVolume, exec, pamixer -d 10"
        ", XF86AudioRaiseVolume, exec, pamixer -i 10"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"

        # Switch between windows in a floating workspace
        "SUPER, Tab, cyclenext,"
        "SUPER, Tab, bringactivetotop,"

        # Move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
      ]
      ++ (builtins.genList (i: "$mainMod, ${toString (i + 1)}, workspace, ${toString (i + 1)}") 9)
      ++ [ "$mainMod, 0, workspace, 10" ]
      ++ (builtins.genList (i: "$mainMod SHIFT, ${toString (i + 1)}, movetoworkspace, ${toString (i + 1)}") 9)
      ++ [ "$mainMod SHIFT, 0, movetoworkspace, 10" ]
      ++ [
        # Scroll through workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];

    # Move/resize with mainMod + LMB/RMB
    bindm = [
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
      "ALT, mouse:272, resizewindow"
    ];
    };
  };

  # Upstream `~/.config/hypr/colors`
  xdg.configFile."hypr/colors".text = ''
    $background = rgba(1d192bee)
    $foreground = rgba(c3dde7ee)

    $color0 = rgba(1d192bee)
    $color1 = rgba(465EA7ee)
    $color2 = rgba(5A89B6ee)
    $color3 = rgba(6296CAee)
    $color4 = rgba(73B3D4ee)
    $color5 = rgba(7BC7DDee)
    $color6 = rgba(9CB4E3ee)
    $color7 = rgba(c3dde7ee)
    $color8 = rgba(889aa1ee)
    $color9 = rgba(465EA7ee)
    $color10 = rgba(5A89B6ee)
    $color11 = rgba(6296CAee)
    $color12 = rgba(73B3D4ee)
    $color13 = rgba(7BC7DDee)
    $color14 = rgba(9CB4E3ee)
    $color15 = rgba(c3dde7ee)
  '';
}
