# Heinz variant rice — curated adaptation of HeinzDev/Hyprland-dotfiles.
# Palette: Nightfox Dusk-ish (hyprgradient 33ccffee → 00ff99ee).
# Terminal: kitty + alacritty. Launcher: rofi (dracula). Notifications: dunst.
# Bar: waybar with cava-internal + powermenu. Wallpaper daemon: swww.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  inherit (import ../shared/wallpapers.nix { inherit pkgs lib; }) heinz heinz-rofi;

  # Nightfox-Dusk-aligned palette (from reference dotfiles)
  bg = "1E1F29"; # base00
  bgAlt = "282A36"; # base01
  fg = "F4F4F9"; # foreground
  fgDim = "9A9FB8";
  cyan = "33CCFF"; # hypr active gradient
  green = "00FF99"; # hypr gradient
  turquoise = "B5E8E0"; # workspaces active
  purple = "BD93F9"; # drcula selected / mpd
  pink = "F5C2E7"; # cpu
  blue = "7EBAE4"; # launcher / network
  gold = "F1D8A9";
  red = "F28FAD"; # powermenu / urgent
  inactive = "595959";

  font = "JetBrainsMono Nerd Font";
in
{
  home.username = variables.username;

  # Small scripts the bar / keybinds rely on (ported from the reference).
  home.packages = with pkgs; [
    kitty
    alacritty
    rofi
    dunst
    cava
awww
    grimblast
    (pkgs.writeShellScriptBin "wallpaper_default" ''
      ${pkgs.awww}/bin/awww img ${heinz} --transition-type wipe
    '')
    (pkgs.writeShellScriptBin "wallpaper_random" ''
      ${pkgs.awww}/bin/awww img "$(ls ${config.xdg.dataHome}/wallpapers/*.png ${config.xdg.dataHome}/wallpapers/*.jpg 2>/dev/null | shuf -n 1)" --transition-type wipe
    '')
    (pkgs.writeShellScriptBin "cava-internal" ''
      ${pkgs.cava}/bin/cava -p ${config.xdg.configHome}/cava/config1 | sed -u 's/;/\n/g'
    '')
    (pkgs.writeShellScriptBin "rofi-window" ''
      ${pkgs.rofi}/bin/rofi -show window -theme ${config.xdg.configHome}/rofi/theme.rasi
    '')
    (pkgs.writeShellScriptBin "dunst-toggle" ''
      if pgrep -x dunst > /dev/null; then
        ${pkgs.dunst}/bin/dunstctl set-paused toggle
      fi
    '')
  ];

  # ── Hyprland ─────────────────────────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      monitor = [ ",preferred,auto,1" ];

      "$mod" = "SUPER";

      exec-once = [
        "waybar"
        "dunst"
        "awww-daemon"
        "wallpaper_default"
        "wl-paste --watch cliphist store"
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "hyprctl setcursor Bibata-Modern-Classic 24"
      ];

      "general" = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(${cyan}E6) rgba(${green}F2) 45deg";
        "col.inactive_border" = "rgba(${inactive}AA)";
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
          range = 8;
          render_power = 3;
        };
        active_opacity = 1.0;
        inactive_opacity = 0.9;
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1";
        animation = [
          "windows, 1, 3, myBezier, slide"
          "windowsOut, 1, 3, myBezier, slide"
          "fade, 1, 3, myBezier"
          "workspaces, 1, 3, myBezier, slide"
        ];
      };

      input = {
        "kb_layout" = "us";
        follow_mouse = 1;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      windowrulev2 = [
        "float, class:(kitty), title:(Kitty)"
        "float, class:(pavucontrol)"
        "float, title:^(Open Files)"
        "center, class:(mpv)"
        "center, class:(pavucontrol)"
      ];

      layerrule = [
        "noanim, launcher"
        "blur, launcher"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bind =
        [
          "$mod, Return, exec, kitty"
          "$mod, d, exec, rofi -show drun -theme ${config.xdg.configHome}/rofi/theme.rasi"
          "$mod, e, exec, rofi-window"
          "$mod, Q, killactive"
          "$mod, F, fullscreen"
          "$mod, M, exit"
          "$mod, S, togglespecialworkspace, scratch"
          "$mod SHIFT, S, movetoworkspace, special:scratch"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, T, exec, wallpaper_random"
          ", Print, exec, grimblast --freeze copy area"
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

  # ── Waybar (heinz floating pill bar) ─────────────────────────────────────
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "${font}";
        font-size: 12px;
        font-weight: 500;
        min-height: 0;
      }
      window#waybar {
        background: transparent;
        color: #${fg};
      }
      tooltip {
        background: #${bg};
        border: 1px solid #${bgAlt};
        border-radius: 8px;
      }
      #custom-launcher, #workspaces, #clock,
      #cpu, #memory, #network, #cava-internal, #pulseaudio,
      #battery, #custom-powermenu {
        background: #1e1e2a;
        border: 2px solid #${cyan}55;
        border-radius: 8px;
        padding: 2px 10px;
        margin: 6px 3px;
        color: #${fg};
      }
      #workspaces button {
        background: transparent;
        color: #${fgDim};
        border-radius: 6px;
        padding: 0 6px;
      }
      #workspaces button.active {
        color: #1e1e2a;
        background: #${turquoise};
        font-weight: 700;
      }
      #workspaces button:hover {
        background: #${bgAlt};
      }
      #custom-launcher { color: #${blue}; }
      #cpu { color: #${pink}; }
      #memory { color: #${turquoise}; }
      #network { color: #${green}; }
      #cava-internal { color: #${cyan}; }
      #pulseaudio { color: #${purple}; }
      #battery { color: #${green}; }
      #battery.critical { color: #${red}; }
      #custom-powermenu { color: #${red}; }
    '';
    settings.mainBar = {
      layer = "top";
      position = "top";
      spacing = 0;
      margin-top = 4;
      margin-bottom = 0;
      modules-left = [
        "custom/launcher"
        "hyprland/workspaces"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "cava-internal"
        "memory"
        "network"
        "pulseaudio"
        "battery"
        "custom/powermenu"
      ];
      "custom/launcher" = {
        format = "  ";
        tooltip = false;
        on-click = "rofi -show drun -theme ${config.xdg.configHome}/rofi/theme.rasi";
      };
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
        format-alt = "{:%d %b}";
        tooltip = false;
      };
      "cava-internal" = {
        format = "  {}";
        tooltip = false;
        interval = "once";
      };
      memory = { format = "  {used}G"; };
      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  eth";
        format-disconnected = "  off";
        on-click = "nmcli -t -f NAME,STATE con show --active";
      };
      pulseaudio = {
        format = "  {volume}%";
        format-muted = "  mut";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };
      battery = {
        format = "  {capacity}%";
        format-charging = "  {capacity}%";
        format-critical = "  {capacity}%";
      };
      "custom/powermenu" = {
        format = "  ";
        tooltip = false;
        on-click = "kill -9 $(pgrep -f 'hyprland')";
      };
    };
  };

  # ── Launcher: rofi (dracula theme, ported) ───────────────────────────────
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus";
      font = "${font} 12";
      location = 0;
      width = 30;
      lines = 12;
      padding = 4;
    };
  };

  xdg.configFile."rofi/theme.rasi".text = ''
      * {
        font: "JetBrainsMono Nerd Font 12";
        background:     #1E1F29;
        background-alt: #282A36;
        foreground:     #F4F4F9;
        selected:       #BD93F9;
        active:         #50FA7B;
        urgent:         #FF5555;
      }
      window {
        background-color: @background;
        border: 2px solid @background-alt;
        border-radius: 8px;
      }
      mainbox {
        background-color: transparent;
        padding: 12px;
      }
      inputbar {
        background-color: @background-alt;
        border-radius: 6px;
        padding: 6px 10px;
        children: [ "prompt", "entry" ];
      }
      prompt {
        text-color: @selected;
      }
      entry {
        text-color: @foreground;
      }
      listview {
        background-color: transparent;
        lines: 12;
        spacing: 4px;
        margin: 8px 0 0 0;
      }
      element {
        background-color: transparent;
        text-color: @foreground;
        padding: 6px 8px;
        border-radius: 6px;
      }
      element selected {
        background-color: @background-alt;
        text-color: @foreground;
      }
      element-icon {
        size: 24px;
        padding: 0 8px 0 0;
      }
      element-text {
        text-color: inherit;
      }
      element alternate selected {
        background-color: @background-alt;
      }
      message {
        background-color: transparent;
      }
      error-message {
        background-color: @background;
      }
    '';

  # ── Terminal: kitty (primary) + alacritty ────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 12;
      window_padding_width = 10;
      background_opacity = 0.9;
      # Nightfox Dusk-ish palette
      background = "#1E1F29";
      foreground = "#F4F4F9";
      cursor = "#F4F4F9";
      selection_background = "#282A36";
      url_color = "#33CCFF";
      active_tab_foreground = "#F4F4F9";
      active_tab_background = "#33CCFF";
      inactive_tab_foreground = "#9A9FB8";
      inactive_tab_background = "#16171f";
      color0 = "#1E1F29";
      color1 = "#7CB7C2";
      color2 = "#9DC7A7";
      color3 = "#F0C987";
      color4 = "#A9A8D6";
      color5 = "#D9A9A8";
      color6 = "#A9B7D6";
      color7 = "#F4F4F9";
      color8 = "#282A36";
      color9 = "#7CB7C2";
      color10 = "#9DC7A7";
      color11 = "#F0C987";
      color12 = "#A9A8D6";
      color13 = "#D9A9A8";
      color14 = "#A9B7D6";
      color15 = "#F4F4F9";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        opacity = 0.9;
      };
      font = {
        normal.family = "Hack";
        size = 12;
      };
      shell = {
        program = "zsh";
      };
      colors = {
        primary = {
          background = "#1E1F29";
          foreground = "#F4F4F9";
        };
        normal = {
          black = "#1E1F29";
          red = "#7CB7C2";
          green = "#9DC7A7";
          yellow = "#F0C987";
          blue = "#A9A8D6";
          magenta = "#D9A9A8";
          cyan = "#A9B7D6";
          white = "#F4F4F9";
        };
        bright = {
          black = "#282A36";
          red = "#7CB7C2";
          green = "#9DC7A7";
          yellow = "#F0C987";
          blue = "#A9A8D6";
          magenta = "#D9A9A8";
          cyan = "#A9B7D6";
          white = "#F4F4F9";
        };
      };
    };
  };

  # ── Notifications: dunst ─────────────────────────────────────────────────
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        width = 300;
        height = 100;
        origin = "top-right";
        offset = "15x15";
        scale = 0;
        notification_limit = 10;
        progress_bar = true;
        progress_bar_height = 6;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 100;
        progress_bar_max_width = 250;
        corner_radius = 8;
        rounded_corners = [ "all" ];
        background_color = "#282A36E6";
        foreground_color = "#F4F4F9";
        frame_color = "#1E1F29";
        frame_width = 2;
        font = "JetBrainsMono Nerd Font 11";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        ellipsize = "end";
        markup = "full";
        plain_text = false;
        word_wrap = true;
        idle_threshold = 5;
        show_age_threshold = 60;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
      };
      urgency_low = {
        background_color = "#282A36";
        foreground_color = "#9A9FB8";
        timeout = 5;
      };
      urgency_normal = {
        background_color = "#282A36";
        foreground_color = "#F4F4F9";
        timeout = 8;
      };
      urgency_critical = {
        background_color = "#1E1F29";
        foreground_color = "#F28FAD";
        frame_color = "#F28FAD";
        timeout = 0;
      };
    };
  };

  # ── Cava (bar visualiser) ────────────────────────────────────────────────
  xdg.configFile."cava/config1".text = ''
    [general]
    framerate = 60
    autosens = 1
    overlay = 0
    bar_delimiter = 0
    bars = 18
    chan_count = 1

    [input]
    method = pulse

    [output]
    method = raw
    data_format = ascii
    ascii_max_range = 8
    bar_spacing = 1
    bar_width = 2

    [color]
    gradient = 1
    gradient_count = 8
    1 = #33CCFF
    2 = #33CCFF
    3 = #38E0B0
    4 = #00FF99
    5 = #9DC7A7
    6 = #A9A8D6
    7 = #F0C987
    8 = #F4F4F9
    background = #1E1F29
  '';

  # ── Lock: hyprlock (dusk frame) ──────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "screenshot";
          color = "rgba(1E1F29CC)";
          blur_passes = 3;
          blur_size = 6;
        }
      ];
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] date +\"%H:%M\"";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 84;
          color = "rgba(F4F4F9E6)";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] date +\"%A  %d %B  %Y\"";
          font_family = "JetBrainsMono Nerd Font";
          font_size = 22;
          color = "rgba(33CCFFCC)";
          position = "0, 55";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 60";
          outline_thickness = 2;
          rounding = 8;
          dots_size = 0.2;
          dots_spacing = 0.5;
          outer_color = "rgba(33CCFFCC)";
          inner_color = "rgba(282A36F2)";
          font_color = "rgba(F4F4F9FF)";
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

  # ── Wallpapers installed for the random script ───────────────────────────
  home.file = {
    "${config.xdg.dataHome}/wallpapers/menhera.jpg" = {
      source = heinz;
    };
    "${config.xdg.dataHome}/wallpapers/rofi.png".source = heinz-rofi;
  };

  gtk.cursorTheme = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}