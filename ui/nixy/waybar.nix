# Waybar ported from anotherhadi/nixy (home/system/waybar/
# {settings.nix,style.nix,default.nix}). stylix colours and config.theme are
# replaced by the local theme; the NUR `settuings` on-clicks are pointed at the
# standard pavucontrol/blueman/nm tools instead.
{ pkgs, scripts, ... }:
let
  t = import ./theme.nix;
  c = t.colors;
  font = t.fonts.sansSerif;
  fontSize = "13px";
  fontSizeClock = "15px";
  modulePadding = "14px";
in
{
  programs.waybar = {
    enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        height = t.barHeight;
        margin = "${toString t.gapsOut} ${toString t.gapsOut} 0";
        modules-center = [
          "custom/osd"
          "custom/osd-sep"
          "clock"
          "tray"
          "hyprland/workspaces"
          "custom/network"
          "custom/bluetooth"
          "battery"
          "group/drawer"
        ];

        "hyprland/workspaces" = {
          format = "{id}";
          all-outputs = true;
          move-to-monitor = true;
          ignore-workspaces = [ "[5-9]" "[1-9][0-9]+" ];
          on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e+1";
          on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e-1";
          persistent-workspaces."*" = [ 1 2 3 4 ];
          cursor = true;
        };

        battery = {
          interval = 20;
          full-at = 100;
          tooltip = true;
          format = "{icon} ";
          format-charging = "󰂄 {icon} ";
          format-icons = [ "" "" "" "" "" ];
          tooltip-format = "{capacity}%  ·  {time}";
          tooltip-format-full = "Full\n{capacity}%";
          tooltip-format-charging = "Charging\n{capacity}%  ·  {time}";
          on-click = "${pkgs.ghostty}/bin/ghostty +new-window -e btop";
          states = {
            warning = 30;
            critical = 15;
          };
        };

        "custom/caffeine" = {
          exec = "${pkgs.coreutils}/bin/printf '󰅶'";
          exec-if = "! systemctl --user is-active --quiet hypridle";
          format = "{}";
          interval = 5;
          on-click = "${scripts.caffeine-toggle}/bin/caffeine-toggle";
          tooltip = false;
        };

        "custom/nightshift" = {
          exec = "${pkgs.coreutils}/bin/printf '󰖔'";
          exec-if = "${pkgs.procps}/bin/pgrep -x hyprsunset";
          format = "{}";
          interval = 5;
          on-click = "${scripts.nightshift-toggle}/bin/nightshift-toggle";
          tooltip = false;
        };

        "custom/bluetooth" = {
          exec = "${scripts.bluetoothScript}";
          exec-if = "${pkgs.bluez}/bin/bluetoothctl list 2>/dev/null | grep -q Controller";
          return-type = "json";
          interval = 5;
          on-click = "${pkgs.blueman}/bin/blueman-manager";
        };

        "custom/osd" = {
          exec = "cat ${scripts.osdPath}";
          exec-if = "${scripts.waybar-osd-status}/bin/waybar-osd-status";
          signal = 8;
          interval = 1;
          format = "{}";
        };

        "custom/osd-sep" = {
          exec = "echo '|'";
          exec-if = "${scripts.waybar-osd-status}/bin/waybar-osd-status";
          signal = 8;
          interval = 1;
          format = "{}";
          tooltip = false;
        };

        pulseaudio = {
          format = "{icon}";
          format-bluetooth = "{icon}";
          tooltip-format = "{volume}%";
          format-muted = "<span size='12pt'>󰝟</span>";
          scroll-step = 2;
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
        };

        "pulseaudio/slider" = {
          min = 0;
          max = 100;
          cursor = true;
        };

        "custom/network" = {
          exec = "${scripts.networkScript}";
          return-type = "json";
          interval = 10;
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };

        tray = {
          icon-size = 13;
          spacing = 12;
          cursor = true;
        };

        clock = {
          timezone = "Asia/Kolkata";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M}";
          format-alt = "{:%H:%M %d %B %Y}";
          calendar = {
            mode = "month";
            format = {
              months = "<span color='#${c.base04}'><b>{}</b></span>";
              weekdays = "<span color='#${c.base0A}'><b>{}</b></span>";
              days = "<span color='#${c.base05}'>{}</span>";
              today = "<span color='#${c.base0D}'><b><u>{}</u></b></span>";
            };
          };
        };

        "group/drawer" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 300;
            children-class = "drawer-child";
            transition-left-to-right = false;
          };
          modules = [
            "custom/arrow-right"
            "pulseaudio"
            "custom/nightshift"
            "custom/caffeine"
          ];
        };

        "custom/arrow-right" = {
          format = " ";
          tooltip = false;
          cursor = true;
        };
      }
    ];

    style = ''
      * {
          font-family: '${font}';
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 0;
          padding: 0;
          text-shadow: none;
      }

      #waybar {
          font-weight: 700;
          background: transparent;
          font-size: ${fontSize};
          color: #${c.base05};
      }

      .modules-center {
          background: #${c.base01};
          border-radius: 100px;
          padding: 6px 14px;
          box-shadow: none;
      }

      #clock,
      #battery,
      #tray,
      #workspaces,
      #custom-osd,
      #custom-network,
      #custom-bluetooth,
      #custom-caffeine,
      #custom-nightshift,
      #pulseaudio {
          padding: 1px ${modulePadding};
      }

      #custom-arrow-right {
          color: #${c.base05};
          padding: 1px 8px;
      }

      #group-drawer {
          padding: 0;
      }

      #custom-osd-sep {
          padding: 0;
          color: #${c.base03};
      }

      #clock {
        font-size: ${fontSizeClock};
      }

      #workspaces button {
          color: #${c.base05};
          font-size: ${fontSize};
          border-radius: 100px;
          padding: 0 3px;
          margin: 0;
      }

      #workspaces button.empty {
          color: #${c.base03};
      }

      #workspaces button:hover {
          background: transparent;
          color: #${c.base05};
      }

      #workspaces button.active {
          color: #${c.base01};
          background: #${c.base0D};
          border-radius: 60px;
          padding: 0 8px;
          margin: 0;
      }

      #battery {
          color: #${c.base0B};
      }

      #battery.charging,
      #battery.full {
          color: #${c.base0B};
      }

      #battery.critical,
      #custom-network.disconnected {
          color: #${c.base08};
      }

      #battery.warning {
          color: #${c.base0A};
      }

      #custom-network.ethernet,
      #custom-network.wifi {
          color: #${c.base0C};
      }

      #custom-bluetooth {
          color: #${c.base0D};
      }

      #custom-bluetooth.off {
          color: #${c.base03};
      }

      #custom-caffeine,
      #custom-nightshift {
          color: #${c.base0A};
      }

      #custom-osd {
          font-weight: 700;
          color: #${c.base05};
      }

      tooltip {
          border-radius: 15px;
          background: #${c.base01};
      }

      tooltip label {
          padding: 3px 10px;
          color: #${c.base05};
          font-weight: 700;
      }

      .popup * {
          box-shadow: none;
          outline: none;
          border-radius: 10px;
      }

      menu {
          border-radius: 10px;
          font-weight: 700;
          color: #${c.base05};
          background: #${c.base01};
      }

      menu > * {
          padding: 3px 0px;
      }

      menu > *:hover {
          border-radius: 10px;
          background-color: #${c.base02};
      }
    '';
  };

  home.packages = with pkgs; [
    playerctl
    pavucontrol
    blueman
    hyprsunset
    networkmanagerapplet
  ];

  # Poll battery level every 30s (battery-monitor no-ops when no battery exists).
  systemd.user.services.battery-monitor = {
    Unit.Description = "Low-battery OSD and critical notification monitor";
    Service = {
      Type = "oneshot";
      ExecStart = "${scripts.battery-monitor}/bin/battery-monitor";
    };
  };

  systemd.user.timers.battery-monitor = {
    Unit.Description = "Poll battery level for low-battery alerts";
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "30s";
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # We use the custom/bluetooth module instead of the blueman applet.
  xdg.configFile."autostart/blueman.desktop".text = ''
    [Desktop Entry]
    Hidden=true
  '';

  wayland.windowManager.hyprland.settings.exec-once = [ "waybar" ];
}
