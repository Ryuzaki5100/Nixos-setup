# Shared Home-Manager userland for the three Hyprland variants.
# All heavy user config lives here; variant home.nix files stay ~15 lines.
{ pkgs, lib, variables, config, ... }:
let
  accent = variables.accent or "89b4fa";
  term   = variables.term or "ghostty";
  launch = variables.launcher or "rofi";
  acBar  = "#${accent}cc";
  termCmd = "${term}";
in
{
  # ── hyprland.conf delivered verbatim: $MOD stays literal for Hyprland ─────
  xdg.configFile."hypr/hyprland.conf".text = ''
    # Hyprland shared config — variant files may extend this.
    monitor = ,preferred,auto,1

    general {
      gaps_in = 2
      gaps_out = 8
      border_size = 2
      col.active_border = ${acBar} 89d4eb 45deg
      col.inactive_border = rgba(313244CC)
      layout = dwindle
    }

    decoration {
      rounding = 8
      blur {
        enabled = true
        size = 4
        passes = 2
      }
      active_opacity = 1.0
      inactive_opacity = 0.95
    }

    animations {
      enabled = true
      bezier = ease, 0.05, 0.9, 0.1, 1
      animation = windows, 1, 4, ease, popin
      animation = fade, 1, 4, ease
    }

    $mod = SUPER

    bind = $mod, Return, exec, ${termCmd}
    bind = $mod, Space, exec, ${launch}
    bind = $mod, Q, killactive
    bind = $mod, F, fullscreen
    bind = $mod, M, exit
    bind = $mod, S, togglespecialworkspace, scratch
    bind = $mod SHIFT, S, movetoworkspace, special:scratch
    bind = $mod, H, movefocus, l
    bind = $mod, L, movefocus, r
    bind = $mod, K, movefocus, u
    bind = $mod, J, movefocus, d
    bind = $mod, 1, workspace, 1
    bind = $mod, 2, workspace, 2
    bind = $mod, 3, workspace, 3
    bind = $mod, 4, workspace, 4
    bind = $mod, 5, workspace, 5
    bind = $mod, 6, workspace, 6
    bind = $mod, 7, workspace, 7
    bind = $mod, 8, workspace, 8
    bind = $mod, 9, workspace, 9
  '';

  # ── Status bar: Waybar ────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    style = ''
      * { font-family: "JetBrainsMono Nerd Font"; font-size: 12px; }
      window#waybar { background: #0f1220; color: #cdd6f4; border-bottom: 2px solid ${acBar}; }
      #workspaces button.active { background: ${acBar}; color: #0f1220; }
      #clock { padding: 0 12px; }
      #pulseaudio, #network, #battery { padding: 0 8px; }
    '';
    settings.mainBar = {
      layer = "top";
      position = "top";
      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" ];
      "hyprland/workspaces" = { format = "{name}"; };
      clock = { format = "{:%H:%M}"; };
      pulseaudio = { format = "{icon} {volume}%"; on-click = "pamixer -t"; };
      network = { format-wifi = "{signalStrength}%"; format-ethernet = "eth"; format-disconnected = "off"; };
      battery = { format = "{capacity}%"; };
    };
  };

  # ── Notifications: Sway Notification Center ──────────────────────────────
  services.swaync = {
    enable = true;
    style = ''
      .notification-row { outline: none; }
      .notification { background: #1e1e2e; border: 1px solid ${acBar}; border-radius: 10px; }
    '';
  };

  # ── Common Wayland user packages ─────────────────────────────────────────
  home.packages = with pkgs; [
    # Wayland tooling
    wl-clipboard
    wayland-utils
    grim
    slurp
    satty
    wf-recorder
    hyprpicker
    cliphist

    # Audio / brightness / media
    pamixer
    playerctl
    brightnessctl
    pavucontrol
    wireplumber

    # Idle / lock / hydrate
    hypridle
    hyprlock

    # GTK theming
    papirus-icon-theme
    adw-gtk3
    gnome-themes-extra
  ];

  # ── GTK / Qt dark theming ─────────────────────────────────────────────────

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    COLORTERM = "truecolor";
  };
}
