# Frost variant rice — faithful adaptation of Frost-Phoenix/nixos-config.
# Palette: gruvbox (dark hard). Layout: dwindle. Terminal: ghostty (gruvbox).
# Launcher: rofi (gruvbox theme + powermenu). Notifications: swaync (gruvbox).
# Bar: waybar (bottom, Maple Mono 18 bold). Lockscreen: hyprlock (forest_road).
# Wallpaper daemon: waypaper (awww backend). Shell: zsh + powerlevel10k.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  inherit (import ../shared/wallpapers.nix { inherit pkgs lib; }) frost frost-hyprlock;

  # gruvbox dark hard palette (reference: modules/home/waybar/style.nix)
  bg0 = "1D2021";
  bg1 = "282828";
  bg2 = "32302F";
  fg = "FBF1C7";
  fg2 = "EBDBB2";
  gray = "928374";
  borderCol = "A89984";
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
    udiskie
    networkmanagerapplet
    grimblast
    swappy

    # Ported scripts
    (pkgs.writeShellScriptBin "init-wallpaper" ''
      ${pkgs.waypaper}/bin/waypaper --restore
    '')
    (pkgs.writeShellScriptBin "random-wallpaper" ''
      ${pkgs.waypaper}/bin/waypaper --random
    '')
    (pkgs.writeShellScriptBin "wallpaper-picker" ''
      ${pkgs.waypaper}/bin/waypaper
    '')
    (pkgs.writeShellScriptBin "screenshot" ''
      dir="$HOME/Pictures/Screenshots"
      time=$(date +'%Y_%m_%d_at_%Hh%Mm%Ss')
      file="''${dir}/Screenshot_''${time}.png"
      if [[ ! -d "$dir" ]]; then mkdir -p "$dir"; fi
      if [[ "$1" == "--save" ]]; then
        GRIMBLAST_HIDE_CURSOR=0 ${pkgs.grimblast}/bin/grimblast --notify --freeze save area "$file"
      elif [[ "$1" == "--swappy" ]]; then
        GRIMBLAST_HIDE_CURSOR=0 ${pkgs.grimblast}/bin/grimblast --notify --freeze save area "$file"
        ${pkgs.swappy}/bin/swappy -f "$file"
      else
        GRIMBLAST_HIDE_CURSOR=0 ${pkgs.grimblast}/bin/grimblast --notify --freeze copy area
      fi
    '')
    (pkgs.writeShellScriptBin "power-menu" ''
      red='${"#" + red}'
      green='${"#" + green}'
      blue='${"#" + blue}'
      yellow='${"#" + yellow}'
      gray='${"#" + borderCol}'
      shutdown="<span color=''${red}'>󰐥</span>"
      reboot="<span color=''${green}'>󰜉</span>"
      lock="<span color=''${blue}'>󰌾</span>"
      suspend="<span color=''${yellow}'>󰤄</span>"
      quit="<span color=''${gray}'>✘</span>"
      yes="<span color=''${green}'>✔</span>"
      no="<span color=''${red}'>✘</span>"
      theme="$HOME/.config/rofi/powermenu-theme.rasi"
      rofi_cmd() {
        ${pkgs.rofi}/bin/rofi -dmenu -theme "''${theme}" -markup-rows
      }
      run_rofi() {
        echo -e "$shutdown\n$reboot\n$lock\n$suspend\n$quit" | rofi_cmd
      }
      confirm_cmd() {
        ${pkgs.rofi}/bin/rofi -theme-str 'window {width: 200px;}' \
          -theme-str 'listview { columns: 2; }' \
          -dmenu -theme "''${theme}" -markup-rows
      }
      rofi_confirm() {
        echo -e "$yes\n$no" | confirm_cmd
      }
      run_cmd() {
        selected="$(rofi_confirm)"
        if [[ "$selected" == "$yes" ]]; then
          if [[ $1 == '--shutdown' ]]; then
            systemctl poweroff
          elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
          elif [[ $1 == '--suspend' ]]; then
            hyprlock &
            systemctl suspend
          fi
        else
          exit 0
        fi
      }
      chosen="$(run_rofi)"
      case "''${chosen}" in
        $shutdown) run_cmd --shutdown ;;
        $reboot)   run_cmd --reboot ;;
        $lock)     sleep 0.1; hyprlock ;;
        $suspend)  sleep 0.1; run_cmd --suspend ;;
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
        "[workspace 2 silent] ghostty"
      ];

      input = {
        kb_layout = "us,fr";
        kb_options = "grp:alt_caps_toggle";
        repeat_delay = 300;
        numlock_by_default = true;
        follow_mouse = 0;
        mouse_refocus = 0;
        float_switch_override_focus = 0;
        touchpad = {
          disable_while_typing = false;
          natural_scroll = true;
        };
      };

      "general" = {
        layout = "dwindle";
        gaps_in = 6;
        gaps_out = 12;
        border_size = 2;
        "col.active_border" = "rgb(98971A) rgb(CC241D) 45deg";
        "col.inactive_border" = "0x00000000";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = false;
        focus_on_activate = true;
        middle_click_paste = false;
        disable_autoreload = false;
      };

      dwindle = {
        force_split = 2;
        preserve_split = true;
        use_active_for_splits = true;
      };

      master = {
        new_status = "master";
      };

      decoration = {
        rounding = 0;
        blur = {
          enabled = true;
          size = 3;
          noise = 0;
          passes = 2;
          contrast = 1.4;
          brightness = 1;
          xray = true;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          offset = "0 2";
          color = "rgba(00000055)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "fluent_decel, 0, 0.2, 0.4, 1"
          "easeOutCirc, 0, 0.55, 0.45, 1"
          "easeOutCubic, 0.33, 1, 0.68, 1"
          "fade_curve, 0, 0.55, 0.45, 1"
        ];
        animation = [
          "windowsIn,   0, 4, easeOutCubic,  popin 20%"
          "windowsOut,  0, 4, fluent_decel,  popin 80%"
          "windowsMove, 1, 2, fluent_decel, slide"
          "fadeIn,      1, 3,   fade_curve"
          "fadeOut,     1, 3,   fade_curve"
          "fadeSwitch,  0, 1,   easeOutCirc"
          "fadeShadow,  1, 10,  easeOutCirc"
          "fadeDim,     1, 4,   fluent_decel"
          "workspaces,  1, 4,   easeOutCubic, fade"
        ];
      };

      xwayland = {
        force_zero_scaling = true;
      };

      windowrule = [
        "match:class ^(imv)$, float on"
        "match:class ^(mpv)$, float on"
        "match:class ^(zenity)$, float on"
        "match:class ^(waypaper)$, float on"
        "match:class ^(org.gnome.Calculator)$, float on"
        "match:class ^(org.pulseaudio.pavucontrol)$, float on"
        "match:class ^(rofi)$, pin on"
        "match:class ^(waypaper)$, pin on"
        "match:class ^(zenity)$, size 850 500"
        "match:title ^(Volume Control)$, size 700 450"
        "match:title ^(Volume Control)$, move 40 55%"
        "match:title ^(Picture-in-Picture)$, pin on"
        "match:title ^(Picture-in-Picture)$, float on"
        "match:class ^(mpv)$, idle_inhibit focus"
      ];

      layerrule = [
        "match:namespace rofi, dim_around on"
        "match:namespace swaync-control-center, dim_around on"
      ];

      workspace = [
        "w[tv1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"
      ];

      binds = {
        scroll_event_delay = 100;
        movefocus_cycles_fullscreen = true;
      };

      windowrulev2 = [
        "float, class:(pavucontrol)"
        "center, class:(pavucontrol)"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];

      bind =
        [
          "$mod, Return, exec, ghostty --gtk-single-instance=true"
          "$mod SHIFT, Return, exec, [fullscreen] ghostty"
          "$mod, Space, exec, rofi -show drun -theme ${config.xdg.configHome}/rofi/theme.rasi"
          "$mod SHIFT, Space, exec, rofi -show run -theme ${config.xdg.configHome}/rofi/theme.rasi"
          "$mod, Q, killactive"
          "$mod, F, fullscreen, 0"
          "$mod SHIFT, F, fullscreen, 1"
          "$mod, M, exit"
          "$mod, C, exec, hyprpicker -a"
          "$mod, Escape, exec, hyprlock"
          "$mod SHIFT, Escape, exec, power-menu"
          "$mod, V, exec, cliphist list | rofi -dmenu -theme ${config.xdg.configHome}/rofi/theme.rasi | cliphist decode | wl-copy"
          ", Print, exec, screenshot --copy"
          "$mod, Print, exec, screenshot --save"
          "$mod SHIFT, Print, exec, screenshot --swappy"
          "$mod, D, exec, wallpaper-picker"
          "$mod SHIFT, D, exec, hyprctl dispatch exec '[float; size 925 615] waypaper'"
          "$mod, T, exec, ghostty"
          "$mod, G, togglegroup"
          "$mod, Tab, changegroupactive"
          "$mod, N, exec, swaync-client -t -sw"
          "$mod, H, movefocus, l"
          "$mod, L, movefocus, r"
          "$mod, K, movefocus, u"
          "$mod, J, movefocus, d"
          "$mod, E, exec, nautilus"
        ]
        ++ (builtins.genList (i: "$mod, ${toString (i + 1)}, workspace, ${toString (i + 1)}") 9)
        ++ [ "$mod, 0, workspace, 10" ]
        ++ (builtins.genList (i: "$mod SHIFT, ${toString (i + 1)}, movetoworkspacesilent, ${toString (i + 1)}") 9)
        ++ [ "$mod SHIFT, 0, movetoworkspacesilent, 10" ];

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
        ", XF86AudioStop, exec, playerctl stop"
        ", switch:on:Lid Switch, exec, pidof hyprlock || hyprlock"
      ];
    };
  };

  # ── Waybar (bottom, gruvbox, reference settings/style) ─────────────────────
  programs.waybar = {
    enable = true;
    settings.mainBar = (import ./waybar-settings.nix { }).programs.waybar.settings.mainBar;
    style = (import ./waybar-style.nix { }).programs.waybar.style;
  };

  # ── Launcher: rofi (gruvbox, ported verbatim) ─────────────────────────────
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
        width:                       500px;
        location:                    center;
        anchor:                      center;
        margin:                      0px;
        padding:                     0px;
        border:                      2px solid;
        border-radius:               0px;
        border-color:                @border-col;
        background-color:            @bg-col;
    }

    mainbox {
        enabled:                     true;
        border:                      0px solid;
        border-radius:               0px;
        border-color:                @selected-col;
        background-color:            inherit;
        children:                    [ "listview" ];
    }

    listview {
        enabled:                     true;
        lines:                       1;
        columns:                     5;
        cycle:                       true;
        dynamic:                     true;
        scrollbar:                   false;
        layout:                      vertical;
        reverse:                     false;
        fixed-height:                true;
        fixed-columns:               true;
        spacing:                     0px;
        border:                      inherit;
        border-radius:               inherit;
        border-color:                inherit;
        text-color:                  @fg-col;
        background-color:            transparent;
    }

    element {
        enabled:                     true;
        spacing:                     0px;
        padding:                     28px 0px;
        border:                      inherit;
        border-radius:               inherit;
        border-color:                inherit;
        background-color:            inherit;
        text-color:                  @fg-col;
        cursor:                      pointer;
    }

    element-text {
        vertical-align:              0.5;
        horizontal-align:            0.5;
        font:                        inherit;
        text-color:                  inherit;
        background-color:            transparent;
        cursor:                      inherit;
    }

    element selected.normal {
        background-color:            @selected-col;
    }
  '';

  # ── Terminal: ghostty (gruvbox, reference palette) ────────────────────────
  programs.ghostty = {
    enable = true;
    themes.gruvbox = {
      background = "1d2021";
      foreground = "fbf1c7";
      cursor-color = "D5C4A1";
      selection-background = "cell-foreground";
      selection-foreground = "cell-background";
      palette = [
        "0=32302f"
        "1=cc241d"
        "2=98971a"
        "3=d79921"
        "4=458588"
        "5=b16286"
        "6=689d6a"
        "7=ebdbb2"
        "8=928374"
        "9=fb4934"
        "10=b8bb26"
        "11=fabd2f"
        "12=83a598"
        "13=d3869b"
        "14=8ec07c"
        "15=fbf1c7"
      ];
    };
    settings = {
      theme = "gruvbox";
      font-family = "Maple Mono";
      font-size = 16;
      font-feature = [
        "calt"
        "cv66"
        "ss05"
      ];
      scrollback-limit = 100000000;
      background-opacity = 0.5;
      adjust-cursor-thickness = 1;
      selection-clear-on-copy = true;
      mouse-hide-while-typing = true;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = "none";
      window-theme = "ghostty";
      window-inherit-working-directory = false;
      resize-overlay = "never";
      confirm-close-surface = false;
      app-notifications = "no-clipboard-copy";
      bell-features = "no-attention,no-audio,no-system,no-title,no-border";
      gtk-single-instance = false;
      gtk-tabs-location = "bottom";
      gtk-wide-tabs = false;
      gtk-custom-css = "styles/tabs.css";
      auto-update = "off";
      clipboard-read = "allow";
      clipboard-write = "allow";
      clipboard-paste-protection = false;
      keybind = [
        "clear"
        "ctrl+shift+a=select_all"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab:this"
        "alt+digit_1=goto_tab:1"
        "alt+digit_2=goto_tab:2"
        "alt+digit_3=goto_tab:3"
        "alt+digit_4=goto_tab:4"
        "ctrl+equal=increase_font_size:1"
        "ctrl++=increase_font_size:1"
        "ctrl+-=decrease_font_size:1"
        "ctrl+0=reset_font_size"
        "shift+page_down=scroll_page_down"
        "shift+page_up=scroll_page_up"
      ];
    };
  };

  xdg.configFile."ghostty/styles/tabs.css".text = ''
    headerbar {
        min-height: 30px;
        padding: 0;
        margin: 0;
    }

    tabbar tabbox {
        margin: 0;
        padding: 0;
        min-height: 30px;
        background-color: #1d2021;
    }

    tabbar tabbox tab {
        margin: 0;
        padding: 0;
        color: #fbf1c7;
    }

    tabbar tabbox tab:selected {
        background-color: #282828;
        color: #fbf1c7;
    }

    tabbar tabbox tab label {
        font-size: 18px;
    }
  '';

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
          label = "󰕾 ";
          expand-button-label = "";
          collapse-button-label = "";
          show-per-app = true;
          show-per-app-icon = true;
          show-per-app-label = false;
        };
        backlight = { label = "󰃟 "; };
      };
    };
    style = ''
      :root {
          --bg-primary: #1d2021;
          --bg-secondary: #282828;
          --bg-button: #4E4E4E;
          --bg-button-hover: #5E5E5E;
          --text-primary: #EBDBB2;
          --text-disabled: #5C554A;
          --border-color: #928374;
          --priority-low: #EBDBB2;
          --priority-normal: #83A598;
          --priority-critical: #FB4934;
          --transition-standard: 0.15s ease-in-out;
      }

      * {
          outline: none;
      }

      *:focus {
          outline: none;
          box-shadow: none;
      }

      scrollbar,
      scrollbar slider {
          opacity: 0;
          min-width: 0px;
          min-height: 0px;
          background: transparent;
      }

      .close-button,
      .widget-title>button,
      .widget-dnd switch,
      .widget-menubar>.menu-button-bar>.widget-menubar-container button,
      .widget-inhibitors>button {
          border-radius: 0px;
          border: none;
          box-shadow: none;
          transition: background var(--transition-standard);
      }

      .close-button {
          background: var(--bg-button);
          color: var(--text-primary);
          text-shadow: none;
          padding: 0;
          border-radius: 50%;
          margin-top: 8px;
          margin-right: 8px;
          min-width: 20px;
          min-height: 20px;
      }

      .close-button:hover {
          background: var(--bg-button-hover);
      }

      .notification-row {
          background: none;
      }

      .notification-row:focus,
      .notification-group:focus {
          background: var(--bg-primary);
      }

      .notification-row .notification-background {
          margin: 0px 0px 0px 0px;
      }

      .notification-row .notification-background .notification {
          border-radius: 0px;
          border: 1px solid var(--border-color);
          transition: background var(--transition-standard);
          background: var(--bg-primary);
          padding: 2px 4px;
      }

      .notification-row .notification-background .notification.low {
          border-left: 3px solid var(--priority-low);
      }

      .notification-row .notification-background .notification.normal {
          border-left: 3px solid var(--priority-normal);
      }

      .notification-row .notification-background .notification.critical {
          border-left: 3px solid var(--priority-critical);
      }

      .notification-default-action {
          padding: 4px;
          margin: 0;
          box-shadow: none;
          background: transparent;
          border: none;
          color: var(--text-primary);
          transition: background var(--transition-standard);
          border-radius: 0px;
      }

      .notification-default-action:hover {
          -gtk-icon-filter: none;
          background: var(--bg-primary);
      }

      .notification-content {
          background: transparent;
          border-radius: 0px;
          padding: 0;
      }

      .notification-content .image {
          -gtk-icon-filter: none;
          -gtk-icon-size: 30px;
          border-radius: 50px;
          margin: 0px 7px 0px 0px;
      }

      .notification-content .text-box label {
          filter: none;
      }

      .notification-content .text-box .summary,
      .notification-content .text-box .time,
      .notification-content .text-box .body {
          font-size: 16px;
          background: transparent;
          color: var(--text-primary);
          text-shadow: none;
      }

      .notification-content .text-box .summary,
      .notification-content .text-box .time {
          font-weight: bold;
      }

      .notification-content .text-box .body {
          font-weight: normal;
      }

      .notification-content progressbar {
          margin-top: 4px;
      }

      .notification-content .body-image {
          margin-top: 4px;
          background-color: white;
          -gtk-icon-filter: none;
      }

      .notification-content .inline-reply {
          margin-top: 4px;
      }

      .notification-content .inline-reply .inline-reply-entry {
          background: var(--bg-secondary);
          color: var(--text-primary);
          caret-color: var(--text-primary);
          border: 1px solid var(--border-color);
          border-radius: 0px;
      }

      .notification-group {
          transition: opacity 200ms ease-in-out;
      }

      .control-center {
          background: var(--bg-primary);
          color: var(--text-primary);
          border-radius: 0px;
          border: 2px solid var(--border-color);
          box-shadow: 0 4px 16px rgba(0, 0, 0, 0.5);
      }

      .control-center .control-center-list {
          background: transparent;
      }

      .widget-title>label {
          margin: 8px;
          font-weight: 700;
          font-size: 16px;
      }

      .widget-title>button {
          margin: 8px;
          font-size: 16px;
          background: var(--bg-primary);
          border: 2px solid var(--text-disabled);
          padding: 3px 10px;
          color: var(--text-primary);
          font-weight: 700;
      }

      .widget-dnd,
      .widget-label,
      .widget-volume,
      .widget-slider,
      .widget-backlight {
          margin-left: 8px;
          margin-right: 8px;
          margin-top: 0px;
          margin-bottom: 0px;
      }

      .widget-dnd label,
      .widget-label>label {
          color: var(--text-primary);
          font-size: 18px;
      }

      .widget-mpris {
          margin: 5px;
      }

      .widget-mpris .widget-mpris-player {
          margin: 10px 10px;
          border-radius: 0px;
          box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.75);
          border: 1px solid var(--border-color);
      }

      .widget-mpris .widget-mpris-player .mpris-background {
          filter: blur(2px);
      }

      .widget-mpris .widget-mpris-player .mpris-overlay {
          padding: 16px;
          background-color: rgba(0, 0, 0, 0.55);
      }

      .widget-volume {
          padding: 8px;
          margin-bottom: 8px;
          border-radius: 0px;
        }

      .per-app-volume {
          background-color: var(--bg-secondary);
          padding: 8px;
          margin: 8px;
          border-radius: 0px;
      }

      .widget-slider {
          padding: 8px;
          border-radius: 0px;
      }

      .widget-backlight {
          padding: 8px;
          border-radius: 0px;
          margin-top: -8px;
          margin-bottom: 8px;
      }
    '';
  };

  # ── Lock screen: hyprlock (gruvbox, reference layout) ────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
        fractional_scaling = 0;
      };
      background = [
        {
          monitor = "";
          path = "${frost-hyprlock}";
          color = "rgba(29, 32, 33, 255)";
          blur_passes = 2;
          vibrancy_darkness = 0.0;
        }
      ];
      shape = [
        {
          monitor = "";
          size = "300, 50";
          rounding = 0;
          border_size = 2;
          color = "rgba(102, 92, 84, 0.33)";
          border_color = "rgba(168, 153, 132, 0.95)";
          position = "0, 270";
          halign = "center";
          valign = "bottom";
        }
      ];
      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +'%k:%M')\"";
          font_size = 115;
          font_family = "Maple Mono Bold";
          shadow_passes = 3;
          color = "rgba(235, 219, 178, 0.9)";
          position = "0, -150";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"- $(date +'%A, %B %d') -\"";
          font_size = 18;
          font_family = "Maple Mono";
          shadow_passes = 3;
          color = "rgba(235, 219, 178, 0.9)";
          position = "0, -350";
          halign = "center";
          valign = "top";
        }
        {
          monitor = "";
          text = "  $USER";
          font_size = 15;
          font_family = "Maple Mono Bold";
          color = "rgba(235, 219, 178, 1)";
          position = "0, 284";
          halign = "center";
          valign = "bottom";
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 50";
          rounding = 0;
          outline_thickness = 2;
          dots_spacing = 0.4;
          font_color = "rgba(235, 219, 178, 0.9)";
          font_family = "Maple Mono Bold";
          outer_color = "rgba(168, 153, 132, 0.95)";
          inner_color = "rgba(102, 92, 84, 0.33)";
          check_color = "rgba(152, 151, 26, 0.95)";
          fail_color = "rgba(204, 36, 29, 0.95)";
          capslock_color = "rgba(215, 153, 33, 0.95)";
          bothlock_color = "rgba(215, 153, 33, 0.95)";
          hide_input = false;
          fade_on_empty = false;
          placeholder_text = "<i><span foreground=\"#fbf1c7\">Enter Password</span></i>";
          position = "0, 200";
          halign = "center";
          valign = "bottom";
        }
      ];
      animation = [ "inputFieldColors, 0" ];
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
    [Settings]
    language = en
    folder = ${config.xdg.dataHome}/wallpapers
    monitors = All
    wallpaper = ${config.xdg.dataHome}/wallpapers/frost.png
    backend = awww
    fill = fill
    sort = name
    color = #ffffff
    subfolders = False
    show_hidden = False
    show_gifs_only = False
    post_command = pkill .waypaper-wrapp
    number_of_columns = 3
    awww_transition_type = any
    awww_transition_step = 90
    awww_transition_angle = 0
    awww_transition_duration = 2
    awww_transition_fps = 60
    use_xdg_state = False
  '';

  # ── GTK: Colloid gruvbox + Bibata cursor ─────────────────────────────────
  gtk.cursorTheme = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

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
}