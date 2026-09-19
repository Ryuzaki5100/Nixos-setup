# Nixy variant rice — curated adaptation of anotherhadi/nixy.
# Palette: nixy base16. Theme: rounding 20, bar-height 36, gaps-in 8,
# gaps-out 16, active-opacity .96, inactive .92, blur off, border 2.
# Launcher: tofi (hyprland.top). Terminal: ghostty. Notifications: swaync.
# Wallpaper daemon: hyprpaper.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  inherit (import ../shared/wallpapers.nix { inherit pkgs lib; }) nixy;

  # nixy base16 palette
  base00 = "0A0A0C"; # default bg
  base01 = "110F12"; # lighter bg / pills
  base02 = "2D2A36"; # selection bg
  base03 = "514D63"; # inactive / comments
  base04 = "8E8AA0"; # darkened text
  base05 = "C2BED6"; # default fg
  base06 = "D8D5EA"; # light fg
  base07 = "EAE7F7"; # lightest fg
  base0D = "9E97F8"; # accent (violet)
  base08 = "E07080"; # red
  base0B = "80B880"; # green
  base0C = "70B8C0"; # cyan
  base0A = "C4B060"; # yellow
  base0E = "C090E8"; # purple
  base09 = "D49070"; # orange

  font = "Maple Mono NF";
  barHeight = 36;
  rounding = 20;
  gapsIn = 8;
  gapsOut = 16;
in
{
  home.username = variables.username;

  # Packages specific to nixy.
  home.packages = with pkgs; [
    ghostty
    tofi
    hyprpaper
  ];

  # ── Hyprland ─────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [ ",preferred,auto,1" ];

      "$mod" = "SUPER";

      exec-once = [
        "systemctl --user import-environment"
        "waybar"
        "swaync"
        "cliphist wipe"
        "wl-paste --watch cliphist store"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "hyprctl setcursor BreezeX-RosePine-Linux 24"
      ];

      # Master layout (nixy default)
      "general" = {
        gaps_in = gapsIn;
        gaps_out = gapsOut;
        border_size = 2;
        "col.active_border" = "rgba(${base0D}FF) rgba(${base0A}FF) 45deg";
        "col.inactive_border" = "rgba(${base02}AA)";
        layout = "master";
      };

      decoration = {
        rounding = rounding;
        active_opacity = 0.96;
        inactive_opacity = 0.92;
        shadow = {
          enabled = false;
        };
        blur = {
          enabled = false;
        };
      };

      animations = {
        enabled = true;
        bezier = "ease, 0.05, 0.9, 0.1, 1";
        animation = [
          "windows, 1, 4, ease, popin"
          "windowsOut, 1, 4, ease, popin"
          "fade, 1, 4, ease"
          "workspaces, 1, 4, ease"
        ];
      };

      master = {
        mfact = 0.5;
        "new_status" = "slave";
      };

      input = {
        "kb_layout" = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
      };

      # Scratchpad + floating helpers
      windowrulev2 = [
        "float, class:(zen-bin|zen), title:(Picture in picture)"
        "float, class:(pavucontrol)"
        "float, title:^(Open Files)"
        "float, class:(org.mozilla.firefox), title:(Firefox — Sharing Indicator)"
      ];

      layerrule = [
        "noanim, launcher"
        "noanim, notifications"
        "blur, launcher"
      ];

      binds = {
        movefocus_cycles_fullscreen = true;
      };

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bind =
        [
          "$mod, Return, exec, ghostty"
          "$mod, Space, exec, tofi-drun --drun-launch=true"
          "$mod, Shift, space, exec, tofi-run"
          "$mod, Q, killactive"
          "$mod, F, fullscreen"
          "$mod, M, exit"
          "$mod, S, togglespecialworkspace, scratch"
          "$mod SHIFT, S, movetoworkspace, special:scratch"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          ", Print, exec, grim -g \"$(slurp)\" - | satty --filename - --fullscreen"
        ]
        ++ (builtins.genList (i: "$mod, ${toString (i + 1)}, workspace, ${toString (i + 1)}") 9)
        ++ (builtins.genList (i: "$mod SHIFT, ${toString (i + 1)}, movetoworkspace, ${toString (i + 1)}") 9);

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  # ── Waybar (nixy pill bar) ───────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "${font}";
        font-size: 13px;
        padding: 0;
        margin: 0;
      }
      window#waybar {
        background: transparent;
        color: #${base05};
      }
      tooltip {
        background: #${base00};
        border: 1px solid #${base02};
        border-radius: ${toString rounding}px;
      }
      #workspaces {
        background: #${base01};
        border-radius: 100px;
        padding: 0 ${toString gapsIn}px;
        margin-top: ${toString (gapsOut + 6)}px;
        margin-bottom: ${toString (gapsOut + 6)}px;
      }
      #workspaces button {
        color: #${base04};
        background: transparent;
        border-radius: 100px;
        margin: 4px 2px;
        padding: 0 8px;
      }
      #workspaces button.active {
        color: #${base00};
        background: #${base0D};
      }
      #workspaces button:hover {
        color: #${base0D};
      }
      #clock {
        background: #${base01};
        border-radius: 100px;
        font-size: 16px;
        font-weight: 600;
        padding: 0 18px;
        margin-top: ${toString (gapsOut + 6)}px;
        margin-bottom: ${toString (gapsOut + 6)}px;
        color: #${base07};
      }
      #cpu, #memory, #network, #pulseaudio, #battery, #tray {
        background: #${base01};
        border-radius: 100px;
        padding: 0 12px;
        margin-top: ${toString (gapsOut + 6)}px;
        margin-bottom: ${toString (gapsOut + 6)}px;
        margin-left: 4px;
        color: #${base05};
      }
      #cpu { color: #${base0C}; }
      #memory { color: #${base0A}; }
      #network { color: #${base0B}; }
      #pulseaudio { color: #${base0E}; }
      #battery { color: #${base0B}; }
      #battery.critical { color: #${base08}; }
    '';
    settings.mainBar = {
      layer = "top";
      position = "top";
      spacing = 0;
      margin-top = 0;
      margin-left = gapsOut;
      margin-right = gapsOut;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "cpu" "memory" "network" "pulseaudio" "battery" "tray" ];
      "hyprland/workspaces" = {
        format = "{name}";
        persistent_workspaces = {
          "1" = [ ];
          "2" = [ ];
          "3" = [ ];
          "4" = [ ];
          "5" = [ ];
        };
      };
      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%d %b %Y}";
        tooltip = true;
      };
      cpu = { format = "  {usage:>5}%"; };
      memory = { format = "  {:>5.1f}G"; };
      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "  eth";
        format-disconnected = "  off";
      };
      pulseaudio = {
        format = "  {volume}%";
        format-muted = " mut";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      battery = {
        format = "  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        format-charging = "  {capacity}%";
        format-critical = "  {capacity}%";
      };
      tray = { spacing = 4; };
    };
  };

  # ── Launcher: tofi (nixy-style top pill) ────────────────────────────────
  programs.tofi = {
    enable = true;
    settings = {
      anchor = "top";
      horizontal = true;
      width = 500;
      height = barHeight;
      margin-top = gapsOut;
      padding-left = "18";
      padding-right = "18";
      result-spacing = 16;
      num-results = 8;
      background-color = "#${base00}F0";
      border-color = "#${base01}";
      outline-color = "#${base02}";
      text-color = "#${base05}";
      prompt-color = "#${base0D}";
      selection-color = "#${base0D}";
      default-result-color = "#${base05}";
      corner-radius = "${toString (if rounding < barHeight / 2 then rounding else barHeight / 2)}";
      font = font;
      prompt-text = "  ";
      placeholder = "Search...";
      text-cursor-style = "block";
      terminal = "ghostty";
    };
  };

  # ── Terminal: ghostty ────────────────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "apple-dark";
      font-family = font;
      font-size = 13;
      padding = 10;
      background-opacity = 0.95;
      window-padding-x = 10;
      window-padding-y = 10;
      clipboard-paste-bracketed = true;
      gtk-single-instance = true;
      keybind = [
        "shift+ctrl+tab=new_tab"
        "ctrl+alt+t=new_split:right"
        "ctrl+alt+n=new_split:down"
      ];
    };
  };

  # ── Notifications: swaync ────────────────────────────────────────────────
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-width = 450;
      control-center-height = 700;
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 8;
      control-center-margin-left = 8;
      notification-window-width = 380;
      fit-to-screen = true;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-action = true;
      hide-on-clear = false;
      timeout = 8;
      timeout-low = 6;
      timeout-critical = 0;
      widgets = [
        "dnd"
        "mpris"
        "volume"
        "backlight"
        "notifications"
      ];
      widget-config = {
        dnd = { text = "Do Not Disturb"; };
        mpris = { show-album-art = "always"; };
        volume = { label = " "; };
        backlight = { label = " "; };
      };
    };
    style = ''
      * {
        font-family: "${font}";
      }
      .notification-row {
        outline: none;
        margin: 0;
        padding: 0;
      }
      .notification {
        background: #${base01}F2;
        border: 1px solid #${base02};
        border-radius: ${toString rounding}px;
        margin: 6px 12px;
        padding: 8px;
        color: #${base05};
      }
      .notification.default, .notification.low, .notification.normal {
        background: #${base01}F2;
      }
      .notification.critical {
        background: #${base00}F2;
        border: 1px solid #${base08};
      }
      .notification .time { color: #${base04}; }
      .notification .summary { color: #${base07}; font-weight: 600; }
      .notification .body { color: #${base05}; }
      .control-center {
        background: #${base00}F2;
        border: 1px solid #${base02};
        border-radius: ${toString (rounding + 4)}px;
      }
      .control-center-list { background: transparent; }
      .widget-title, .widget-dnd, .widget-mpris {
        background: #${base01}F2;
        border-radius: ${toString rounding}px;
        color: #${base07};
        margin: 4px 12px;
      }
      .button {
        background: #${base02};
        border-radius: 100px;
        color: #${base05};
      }
      .slider, .slider > slider {
        background: #${base02};
        color: #${base0D};
      }
    '';
  };

  # ── Wallpaper daemon: hyprpaper ──────────────────────────────────────────
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = false;
      preload = [ "${nixy}" ];
      wallpaper = [ ",${nixy}" ];
    };
  };

  # ── Lock screen: hyprlock (nixy box-drawing clock) ───────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "screenshot";
          color = "rgba(${base00}CC)";
          blur_passes = 2;
          blur_size = 6;
        }
      ];
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] ${
              # Box-drawing frame around the clock (nixy style)
              lib.concatStrings [
                "echo -e '╔═══════════════════════════════════════╗\n║  \$(date +\"%H:%M\")  ║\n╚═══════════════════════════════════════╝'"
              ]
            }";
          font_family = "Monospace";
          font_size = 64;
          color = "rgba(${base07}E6)";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] ${
              lib.concatStrings [
                "echo -e '\$(date +\"  %d %b %Y  ·  %A\")'"
              ]
            }";
          font_family = "${font}";
          font_size = 24;
          color = "rgba(${base0D}CC)";
          position = "0, 45";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 2;
          rounding = 12;
          dots_size = 0.2;
          dots_spacing = 0.5;
          outer_color = "rgba(${base0D}FF)";
          inner_color = "rgba(${base01}F2)";
          font_color = "rgba(${base05}FF)";
          placeholder_text = "Password";
          fade_on_empty = true;
          position = "0, -60";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # ── Idle: hypridle ───────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 300;
          on-timeout = "pidof hyprlock || hyprlock";
        }
        {
          timeout = 360;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # ── GTK / Qt
  gtk.cursorTheme = {
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
    size = 24;
  };
}