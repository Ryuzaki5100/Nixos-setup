# Keybinds ported from anotherhadi/nixy (home/system/hyprland/bindings.nix).
# Upstream's custom Helium browser is mapped to Firefox (not in nixpkgs here)
# and the `elio` file manager to yazi; the rest is kept upstream.
{ pkgs, lib, scripts, ... }:
let
  t = import ./theme.nix;
  c = t.colors;

  browser = pkgs.firefox;
  terminal = pkgs.ghostty;

  # wlr-which-key menu (upstream mkMenu)
  mkMenu = menu: let
    configFile = pkgs.writeText "config.yaml" (
      lib.generators.toYAML { } {
        anchor = "top";
        border = "#${c.base0D}EE";
        border_width = t.borderSize;
        background = "#${c.base01}FF";
        color = "#${c.base05}";
        margin_top = 0;
        rows_per_column = 5;
        inherit menu;
      }
    );
  in
  pkgs.writeShellScriptBin "menu" ''
    if ${pkgs.procps}/bin/pkill -x wlr-which-key; then
      exit 0
    fi
    exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
  '';

  tofi-drun-toggle = pkgs.writeShellScriptBin "tofi-drun-toggle" ''
    if ${pkgs.procps}/bin/pkill -x tofi-drun; then
      exit 0
    fi
    exec ${pkgs.tofi}/bin/tofi-drun
  '';
in
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$shiftMod" = "SUPER_SHIFT";

    bind =
      [
        # Applications menu
        (
          "$shiftMod, A, exec, "
          + lib.getExe (mkMenu [
            {
              key = "a";
              desc = "Proton Authenticator";
              cmd = "env WEBKIT_DISABLE_COMPOSITING_MODE=1 ${pkgs.proton-authenticator}/bin/proton-authenticator";
            }
            {
              key = "p";
              desc = "Proton Pass";
              cmd = "${pkgs.proton-pass}/bin/proton-pass";
            }
            {
              key = "v";
              desc = "Proton VPN";
              cmd = "${pkgs.proton-vpn}/bin/protonvpn-app";
            }
            {
              key = "c";
              desc = "Proton Calendar";
              cmd = "${browser}/bin/firefox 'https://calendar.proton.me/'";
            }
            {
              key = "m";
              desc = "Proton Mail";
              cmd = "${browser}/bin/firefox 'https://mail.proton.me/'";
            }
            {
              key = "o";
              desc = "Obsidian";
              cmd = "${pkgs.obsidian}/bin/obsidian";
            }
            {
              key = "s";
              desc = "Signal";
              cmd = "${pkgs.signal-desktop}/bin/signal-desktop";
            }
            {
              key = "t";
              desc = "TickTick";
              cmd = "${pkgs.ticktick}/bin/ticktick";
            }
            {
              key = "b";
              desc = "Firefox";
              cmd = "${browser}/bin/firefox";
            }
            {
              key = "i";
              desc = "Firefox (Private)";
              cmd = "${browser}/bin/firefox --private-window";
            }
          ])
        )

        "$mod,B, exec, ${browser}/bin/firefox" # Browser

        # Power menu
        (
          "$mod, X, exec, "
          + lib.getExe (mkMenu [
            {
              key = "l";
              desc = "Lock";
              cmd = "${pkgs.hyprlock}/bin/hyprlock";
            }
            {
              key = "s";
              desc = "Suspend";
              cmd = "systemctl suspend";
            }
            {
              key = "r";
              desc = "Reboot";
              cmd = "systemctl reboot";
            }
            {
              key = "p";
              desc = "Power Off";
              cmd = "systemctl poweroff";
            }
          ])
        )

        # Quick launch
        "$mod,RETURN, exec, ${terminal}/bin/ghostty +new-window"
        "$mod,E, exec, ${terminal}/bin/ghostty +new-window -e yazi"
        "$mod, SPACE, exec, ${lib.getExe tofi-drun-toggle}"
        "$mod, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t"

        # Windows
        "$mod,Q, killactive,"
        "$mod,F, fullscreen"
        "$shiftMod,F, togglefloating,"
        "$shiftMod, SPACE, exec, ${scripts.focus-toggle}/bin/focus-toggle"

        # Focus windows
        "$mod,H, movefocus, l"
        "$mod,J, movefocus, d"
        "$mod,K, movefocus, u"
        "$mod,L, movefocus, r"
        "$shiftMod,H, focusmonitor, -1"
        "$shiftMod,J, layoutmsg, removemaster"
        "$shiftMod,K, layoutmsg, addmaster"
        "$shiftMod,L, focusmonitor, 1"

        # Special workspaces
        "$mod, S, togglespecialworkspace, scratch"
        "$shiftMod, S, movetoworkspace, special:scratch"

        # Screenshots
        ", Print, exec, ${pkgs.hyprshot}/bin/hyprshot -m region"
        "$shiftMod, Print, exec, ${pkgs.hyprshot}/bin/hyprshot -m output"
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i: let
            ws = i + 1;
          in [
            "$mod,code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT,code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        ) 9
      ));

    bindm = [
      "$mod,mouse:272, movewindow"
      "$mod,R, resizewindow"
    ];

    bindl = [
      # Brightness
      ", XF86MonBrightnessUp, exec, ${scripts.bright-up}/bin/bright-up"
      ", XF86MonBrightnessDown, exec, ${scripts.bright-down}/bin/bright-down"

      # Media
      ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
      ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"

      # Sound
      ", XF86AudioMute, exec, ${scripts.vol-mute}/bin/vol-mute"
      ", XF86AudioRaiseVolume, exec, ${scripts.vol-up}/bin/vol-up"
      ", XF86AudioLowerVolume, exec, ${scripts.vol-down}/bin/vol-down"
      ", XF86AudioMicMute, exec, ${scripts.mic-mute}/bin/mic-mute"
    ];
  };
}
