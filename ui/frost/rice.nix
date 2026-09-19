# Frost variant rice — curated adaptation of Frost-Phoenix/nixos-config.
# Palette: gruvbox (dark hard). Layout: dwindle. Terminal: ghostty (gruvbox).
# Launcher: rofi (gruvbox theme + powermenu). Notifications: swaync (gruvbox).
# Bar: waybar (Maple Mono 18 bold). Wallpaper daemon: waypaper (swww backend).
# Shell: zsh + powerlevel10k.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  inherit (import ../shared/wallpapers.nix { inherit pkgs lib; }) frost;

  # gruvbox dark hard palette
  bg0 = "1D2021";
  bg1 = "282828";
  bg2 = "32302F";
  fg = "FBF1C7";
  fg2 = "EBDBB2";
  gray = "928374";
  red = "CC241D";
  green = "98971A";
  yellow = "D79921";
  brightYellow = "FABD2F";
  blue = "458588";
  brightBlue = "83A598";
  purple = "B16286";
  aqua = "689D6A";
  orange = "D65D0E";
  brightOrange = "FE8019";
  borderCol = "A89984";

  font = "Maple Mono NF";
in
{
  home.username = variables.username;

  home.packages = with pkgs; [
    ghostty
    rofi
    waypaper
    awww
    poweralertd
    wl-clip-persist
    nautilus
    udiskie
    networkmanagerapplet
    grimblast

    # Ported scripts
    (pkgs.writeShellScriptBin "init-wallpaper" ''
      ${pkgs.awww}/bin/awww-daemon
      ${pkgs.waypaper}/bin/waypaper --restore
    '')
    (pkgs.writeShellScriptBin "random-wallpaper" ''
      ${pkgs.waypaper}/bin/waypaper --random
    '')
    (pkgs.writeShellScriptBin "wallpaper-picker" ''
      ${pkgs.waypaper}/bin/waypaper
    '')
    (pkgs.writeShellScriptBin "screenshot" ''
      ${pkgs.grimblast}/bin/grimblast copy area
    '')
    (pkgs.writeShellScriptBin "power-menu" ''
      entries='󰐊 Lock\n󰤄 Suspend\n󰑥 Reboot\n󰐌 Shutdown'
      selected=$(printf '%b' "$entries" | ${pkgs.rofi}/bin/rofi -dmenu -p "" -theme ${config.xdg.configHome}/rofi/powermenu-theme.rasi)
      case "$selected" in
        *Lock) hyprlock ;;
        *Suspend) systemctl suspend ;;
        *Reboot) systemctl reboot ;;
        *Shutdown) systemctl poweroff ;;
      esac
    '')
  ];

  # ── Hyprland (dwindle, gruvbox) ──────────────────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [ ",preferred,auto,1" ];

      "$mod" = "SUPER";

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "hyprctl setcursor Bibata-Modern-Ice 24"
        "waybar"
        "swaync"
        "init-wallpaper"
        "ghostty --gtk-single-instance"
        "poweralertd"
        "wl-clip-persist --clipboard both"
        "nm-applet --indicator"
      ];

      "general" = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "rgb(${green}) rgb(${red}) 45deg";
        "col.inactive_border" = "rgb(${bg1})";
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
        active_opacity = 1.0;
        inactive_opacity = 0.95;
        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
          color = "rgba(1A1B26EE)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 2;
          xray = true;
        };
      };

      animations = {
        enabled = true;
        bezier = "fluent_decel, cubic-bezier(0.1, 0.9, 0.2, 1)";
        animation = [
          "windows, 1, 4, fluent_decel, popin"
          "windowsOut, 1, 4, fluent_decel, popin"
          "fade, 1, 4, fluent_decel"
          "workspaces, 1, 4, fluent_decel, slide"
          "border, 1, 4, fluent_decel"
        ];
      };

      dwindle = {
        pseudotile = true;
        force_split = 2;
        preserve_split = true;
      };

      input = {
        "kb_layout" = "us";
        follow_mouse = 0;
      };

      windowrulev2 = [
        "float, class:(pavucontrol)"
        "float, title:^(Open Files)"
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
          "$mod, Return, exec, ghostty"
          "$mod, Space, exec, rofi -show drun -theme ${config.xdg.configHome}/rofi/theme.rasi"
          "$mod SHIFT, Space, exec, rofi -show run -theme ${config.xdg.configHome}/rofi/theme.rasi"
          "$mod, Q, exec, ghostty nvim"
          "$mod, F, fullscreen"
          "$mod, M, exit"
          "$mod, C, killactive"
          "$mod, L, exec, hyprlock"
          "$mod, V, exec, cliphist list | rofi -dmenu -theme ${config.xdg.configHome}/rofi/theme.rasi | cliphist decode | wl-copy"
          "$mod SHIFT, S, exec, waypaper"
          ", Print, exec, screenshot"
          "$mod, B, exec, zen-browser"
          "$mod, T, exec, ghostty"
          "$mod, G, togglegroup"
          "$mod, Tab, changegroupactive"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, S, exec, power-menu"
          "$mod, E, exec, nautilus"
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

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioPlay, exec, playerctl play-pause"
      ];
    };
  };

  # ── Waybar (gruvbox, Maple Mono bold) ────────────────────────────────────
  programs.waybar = {
    enable = true;
    style = ''
      * {
        font-family: "${font}";
        font-size: 18px;
        min-height: 0;
      }
      window#waybar {
        background: #${bg1};
        color: #${fg2};
        border-top: 1px solid #${borderCol};
      }
      tooltip {
        background: #${bg0};
        border: 1px solid #${borderCol};
        border-radius: 0;
        color: #${fg};
      }
      #workspaces {
        padding: 0 8px;
      }
      #workspaces button {
        background: transparent;
        color: #${gray};
        border-radius: 0;
        padding: 6px 8px;
        margin: 2px 0;
      }
      #workspaces button.active {
        color: #${brightYellow};
        border-bottom: 2px solid #${brightYellow};
      }
      #workspaces button:hover {
        color: #${fg};
      }
      #window {
        padding: 6px 12px;
        color: #${fg2};
      }
      #clock, #battery, #pulseaudio, #network, #cpu, #memory, #tray {
        padding: 6px 12px;
        color: #${fg2};
      }
      #clock { color: #${fg}; }
      #battery { color: #${green}; }
      #battery.warning { color: #${brightOrange}; }
      #battery.critical { color: #${red}; }
      #pulseaudio { color: #${brightBlue}; }
      #pulseaudio.muted { color: #${gray}; }
      #network { color: #${brightOrange}; }
      #network.disconnected { color: #${red}; }
      #cpu { color: #${aqua}; }
      #memory { color: #${purple}; }
      #pulseaudio { padding-right: 0; }
      #clock { padding-left: 0; }
    '';
    settings.mainBar = {
      layer = "top";
      position = "top";
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "tray" "cpu" "memory" "network" "pulseaudio" "battery" ];
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
        format-alt = "{:%A, %d %B %Y}";
        tooltip = true;
      };
      cpu = { format = "  {usage}%"; };
      memory = { format = "  {used:0.1f}G"; };
      network = {
        interface = "wlp2s0";
        format-wifi = "  {signalStrength}%";
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
        format-icons = [ "" "" "" "" "" ];
      };
    };
  };

  # ── Launcher: rofi (gruvbox, ported verbatim) ─────────────────────────────
  # rofi package is in home.packages; config is plain xdg files below.

  xdg.configFile."rofi/config.rasi".text = ''
    configuration{
        modi: "run,drun,window";
        lines: 5;
        cycle: false;
        font: "Maple Mono Bold 16";
        show-icons: true;
        icon-theme: "Papirus-dark";
        terminal: "ghostty";
        drun-display-format: "{icon} {name}";
        location: 0;
        disable-history: true;
        hide-scrollbar: true;
        display-drun: " Apps ";
        display-run: " Run ";
        display-window: " Window ";
        sidebar-mode: true;
        sorting-method: "fzf";
    }

    @theme "theme"

    element-text, element-icon , mode-switcher {
        background-color: inherit;
        text-color:       inherit;
    }

    window {
        height: 539px;
        width: 400px;
        border: 2px;
        border-color: @border-col;
        background-color: @bg-col;
    }

    mainbox {
        background-color: @bg-col;
    }

    inputbar {
        children: [prompt,entry];
        background-color: @bg-col-light;
        padding: 0px;
    }

    prompt {
        background-color: @green;
        padding: 4px;
        text-color: @bg-col-light;
        margin: 10px 0px 10px 10px;
    }

    textbox-prompt-colon {
        expand: false;
        str: ":";
    }

    entry {
        padding: 6px;
        margin: 10px 10px 10px 5px;
        text-color: @fg-col;
        background-color: @bg-col;
    }

    listview {
        border: 0px 0px 0px;
        padding: 0px;
        margin: 0px;
        columns: 1;
        background-color: @bg-col;
        cycle: true;
    }

    element {
        padding: 8px 8px 8px 8px;
        margin: 0px;
        background-color: @element-bg;
        text-color: @fg-col;
    }

    element-icon {
        size: 28px;
    }

    element selected {
        background-color:  @selected-col ;
        text-color: @fg-col2  ;
    }

    element alternate.normal {
        background-color: @element-alternate-bg;
        text-color:       @fg-col;
    }

    mode-switcher {
        spacing: 0;
    }

    button {
        padding: 10px;
        background-color: @bg-col-light;
        text-color: @grey;
        vertical-align: 0.5;
        horizontal-align: 0.5;
    }

    button selected {
        background-color: @bg-col;
        text-color: @green;
    }
  '';

  xdg.configFile."rofi/theme.rasi".text = ''
    * {
        bg-col: #1D2021;
        bg-col-light: #282828;
        border-col: #A89984;
        selected-col: #3C3836;
        green: #98971A;
        fg-col: #FBF1C7;
        fg-col2: #EBDBB2;
        grey: #BDAE93;
        highlight: @green;
        element-bg: #212323;
        element-alternate-bg: #242526;
    }
  '';

  xdg.configFile."rofi/powermenu-theme.rasi".text = ''
    @theme "theme"

    configuration {
      show-icons: false;
      font: "Maple Mono Bold 26";
    }

    window {
      width:           500px;
      location:        center;
      anchor:          center;
      margin:          0px;
      padding:         0px;
      border:          2px solid;
      border-radius:   0px;
      border-color:    @border-col;
      background-color: @bg-col;
    }

    mainbox {
      enabled:         true;
      border:          0px solid;
      border-radius:   0px;
      border-color:    @selected-col;
      background-color: inherit;
      children:        [ "listview" ];
    }

    listview {
      enabled:         true;
      lines:           1;
      columns:         5;
      cycle:           true;
      dynamic:         true;
      scrollbar:       false;
      layout:          vertical;
      spacing:         0px;
      border:          inherit;
      border-radius:   inherit;
      border-color:    inherit;
      text-color:      @fg-col;
      background-color: transparent;
    }

    element {
      enabled:         true;
      spacing:         0px;
      padding:         28px 0px;
      border:          inherit;
      border-radius:   inherit;
      border-color:    inherit;
      background-color: inherit;
      text-color:      @fg-col;
      cursor:          pointer;
    }

    element-text {
      vertical-align:    0.5;
      horizontal-align:  0.5;
      font:              inherit;
      text-color:        inherit;
      background-color:  transparent;
      cursor:            inherit;
    }

    element selected.normal {
      background-color: @selected-col;
    }
  '';

  # ── Terminal: ghostty (gruvbox) ──────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    themes.gruvbox = {
      background = bg0;
      foreground = fg;
      cursor-color = brightYellow;
      selection-background = bg2;
      selection-foreground = fg;
      palette = [
        "0=#${bg2}"
        "1=#${red}"
        "2=#${green}"
        "3=#${brightYellow}"
        "4=#${blue}"
        "5=#${purple}"
        "6=#${aqua}"
        "7=#${gray}"
        "8=#${bg1}"
        "9=#${brightOrange}"
        "10=#${green}"
        "11=#${brightYellow}"
        "12=#${brightBlue}"
        "13=#${purple}"
        "14=#${aqua}"
        "15=#${fg}"
      ];
    };
    settings = {
      theme = "gruvbox";
      font-family = "Maple Mono";
      font-size = 16;
      background-opacity = 0.5;
      window-padding-x = 10;
      window-padding-y = 10;
      gtk-single-instance = true;
      gtk-tabs-location = "bottom";
      ignore-single-instance = false;
      keybind = [
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab"
        "ctrl+pageup=previous_tab"
        "ctrl+pagedown=next_tab"
        "ctrl+shift+enter=new_split:right"
        "ctrl+shift+d=close_split"
      ];
    };
  };

  # ── Notifications: swaync (gruvbox) ──────────────────────────────────────
  services.swaync = {
    enable = true;
    settings = {
      "$schema" = "/etc/xdg/swaync/configSchema.json";
      ignore-gtk-theme = true;
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      layer-shell-cover-screen = true;
      cssPriority = "user";
      control-center-margin-top = 15;
      control-center-margin-bottom = 15;
      control-center-margin-right = 15;
      control-center-margin-left = 0;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-icon-size = 48;
      timeout = 8;
      timeout-low = 6;
      timeout-critical = 0;
      fit-to-screen = true;
      relative-timestamps = true;
      control-center-width = 400;
      control-center-height = 600;
      notification-window-width = 350;
      keyboard-shortcuts = true;
      notification-grouping = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      text-empty = "No Notifications";
      script-fail-notify = true;
      widgets = [
        "dnd"
        "mpris"
        "notifications"
        "volume"
        "backlight"
      ];
      widget-config = {
        inhibitors = {
          text = "Inhibitors";
          button-text = "Clear All";
          clear-all-button = true;
        };
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = { text = "Do Not Disturb"; };
        label = {
          max-lines = 5;
          text = "Label Text";
        };
        mpris = {
          show-album-art = "always";
          loop-carousel = false;
        };
        volume = {
          label = " ";
          expand-button-label = "";
          collapse-button-label = "";
          show-per-app = true;
          show-per-app-icon = true;
        };
        backlight = { label = " "; };
      };
    };
    style = ''
      * {
        font-family: "Maple Mono";
      }

      @define-color bg-primary #${bg0};
      @define-color bg-secondary #${bg1};
      @define-color text-primary #${fg2};
      @define-color text-secondary #${fg};
      @define-color border-color #${gray};
      @define-color highlight #${brightYellow};
      @define-color error #${red};

      .notification-row {
        padding: 0;
        margin: 0;
        background: transparent;
      }

      .notification-row:focus,
      .notification-row:hover {
        background: @bg-primary;
      }

      .notification {
        margin: 4px 8px;
        padding: 0;
        border: 1px solid @border-color;
        border-radius: 0;
        background: @bg-primary;
        color: @text-primary;
      }

      .notification.low {
        border-color: @border-color;
        background: @bg-primary;
      }

      .notification.normal {
        border-color: @border-color;
        background: @bg-primary;
      }

      .notification.critical {
        border-color: @error;
        background: @bg-primary;
        color: @text-secondary;
      }

      .notification .notification-action {
        background: @bg-secondary;
        border: 1px solid @border-color;
        border-radius: 0;
        color: @text-secondary;
      }

      .notification-action:hover {
        color: @highlight;
      }

      .notification-default-action {
        padding: 8px;
        margin: 0;
      }

      .notification-content {
        background: transparent;
        padding: 8px;
      }

      .notification-icon {
        background: transparent;
        color: @text-primary;
      }

      .notification-title {
        color: @text-secondary;
        font-weight: bold;
      }

      .notification-body {
        color: @text-primary;
      }

      .control-center {
        margin: 16px;
        border: 1px solid @border-color;
        border-radius: 0;
        background: @bg-primary;
        color: @text-primary;
      }

      .control-center-list {
        background: @bg-primary;
        padding: 4px 8px;
      }

      .control-center-list-placeholder {
        color: @text-primary;
        background: transparent;
      }

      .widget-title,
      .widget-dnd,
      .widget-mpris,
      .widget-volume,
      .widget-backlight {
        margin: 8px;
        padding: 8px;
        border: 1px solid @border-color;
        border-radius: 0;
        background: @bg-secondary;
        color: @text-primary;
      }

      .widget-title button,
      .widget-dnd button {
        background: @bg-primary;
        border: 1px solid @border-color;
        border-radius: 0;
        color: @text-primary;
      }

      .button {
        background: @bg-primary;
        border: 1px solid @border-color;
        border-radius: 0;
        color: @text-primary;
      }

      .button:hover {
        background: @bg-secondary;
        color: @highlight;
      }

      .slider {
        background: @bg-primary;
      }

      .slider > scale trough {
        background: @bg-secondary;
        min-height: 4px;
        border-radius: 0;
      }

      .slider > scale trough highlight {
        background: @highlight;
        min-height: 4px;
        border-radius: 0;
      }

      .slider > scale slider {
        background: @highlight;
        border-radius: 0;
      }
    '';
  };

  # ── Lock screen: hyprlock (gruvbox) ──────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = "${frost}";
          color = "rgba(29, 32, 33, 255)";
          blur_passes = 2;
          blur_size = 6;
        }
      ];
      shape = [
        {
          monitor = "";
          size = "360, 200";
          color = "rgba(29, 32, 33, 230)";
          rounding = 0;
          rotate = 0;
          position = "0, 0";
          halign = "center";
          valign = "center";
        }
      ];
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] date +\"%H:%M\"";
          font_family = "Maple Mono";
          font_size = 96;
          color = "rgba(235, 219, 178, 255)";
          position = "0, 60";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] date +\"%A  ·  %d %B %Y\"";
          font_family = "Maple Mono";
          font_size = 28;
          color = "rgba(168, 153, 132, 255)";
          position = "0, -10";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] whoami";
          font_family = "Maple Mono";
          font_size = 20;
          color = "rgba(250, 189, 47, 255)";
          position = "0, -70";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "320, 60";
          outline_thickness = 2;
          rounding = 0;
          dots_size = 0.18;
          dots_spacing = 0.6;
          dots_center = false;
          outer_color = "rgba(168, 153, 132, 255)";
          inner_color = "rgba(40, 40, 40, 255)";
          font_color = "rgba(235, 219, 178, 255)";
          placeholder_text = "Password";
          fade_on_empty = true;
          check_color = "rgba(250, 189, 47, 255)";
          fail_color = "rgba(204, 36, 29, 255)";
          position = "0, -120";
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

  # ── Wallpaper daemon: waypaper ───────────────────────────────────────────
  home.file."${config.xdg.dataHome}/wallpapers/frost.png".source = frost;

  xdg.configFile."waypaper/config.ini".text = ''
    [settings]
    folder = ${config.xdg.dataHome}/wallpapers
    backend = awww
    image = frost.png
    position = center
    fill = scale
    fit = contain
    wallpaper = ${config.xdg.dataHome}/wallpapers/frost.png
    language = en
    post_command =
  '';

  # ── Shell: powerlevel10k (override shared starship) ──────────────────────
  programs.starship.enable = lib.mkForce false;
  programs.zsh = {
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
    initContent = lib.mkForce ''
      # Enable Powerlevel10k instant prompt.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  home.file.".p10k.zsh".source = ../../static/p10k.zsh;

  gtk.cursorTheme = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
}