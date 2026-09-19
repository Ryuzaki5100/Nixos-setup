# Nixy variant rice — faithful port of anotherhadi/nixy's home/system config.
# The base16 palette and metrics live in theme.nix (upstream uses stylix); the
# helper scripts in scripts.nix are exposed to the modules via _module.args.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  scripts = import ./scripts.nix { inherit pkgs; };
in
{
  imports = [
    ./hyprland.nix
    ./bindings.nix
    ./waybar.nix
    ./tofi.nix
    ./swaync.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./polkitagent.nix
    ./ghostty.nix
  ];

  _module.args.scripts = scripts;

  home.username = variables.username;

  # ── Packages used by the upstream ricing ─────────────────────────────────
  home.packages =
    (with pkgs; [
      ghostty
      tofi
      hyprshot
      swaynotificationcenter
      wlr-which-key
      hyprpicker
      satty
      imv
      wf-recorder
      cliphist
      jq
      playerctl
      brightnessctl
      wireplumber

      # icons + fonts
      papirus-icon-theme
      material-icons
      material-design-icons
      material-symbols
      maple-mono.NF
      rubik
      noto-fonts-color-emoji
      rose-pine-cursor
    ])
    ++ (with scripts; [
      waybar-osd
      waybar-osd-status
      battery-monitor
      vol-up
      vol-down
      vol-mute
      mic-mute
      bright-up
      bright-down
      nightshift-toggle
      focus-toggle
      waybar-toggle
      wifi-toggle
      bluetooth-toggle
      dnd-toggle
      output-cycle
      input-cycle
      color-pick
      screenshot-edit
      record-toggle
      power-cycle
      airplane-toggle
      clipboard-menu
      emoji-picker
      caffeine-toggle
      mic-status
    ]);

  gtk.cursorTheme = {
    package = pkgs.rose-pine-cursor;
    name = "BreezeX-RosePine-Linux";
    size = 24;
  };
}
