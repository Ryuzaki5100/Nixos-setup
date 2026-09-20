# Frost variant rice — faithful port of Frost-Phoenix/nixos-config.
# The Hyprland config is split exactly like upstream (settings/binds/
# windowrules/exec-once/monitors); launcher, notifications, terminal, lock,
# scripts and the gruvbox waybar all come from the upstream modules.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  inherit (import ../shared/wallpapers.nix { inherit pkgs lib; }) frost;
in
{
  imports = [
    ./settings.nix
    ./binds.nix
    ./windowrules.nix
    ./exec-once.nix
    ./monitors.nix
    ./hyprlock.nix
    ./swaylock.nix
    ./ghostty.nix
    ./kitty.nix
    ./rofi.nix
    ./swaync.nix
    ./scripts.nix
  ];

  home.username = variables.username;

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.configType = "hyprlang";

  # ── Packages used by the upstream ricing ─────────────────────────────────
  home.packages = with pkgs; [
    ghostty
    kitty
    rofi
    swaynotificationcenter
    waypaper
    awww
    poweralertd
    wl-clip-persist
    wl-clipboard
    cliphist
    udiskie
    networkmanagerapplet
    grimblast
    swappy
    hyprpicker
    woomer
    nemo
    hyprshot
    brightnessctl
    pamixer
    playerctl
    bibata-cursors
  ];

  # ── Waybar (bottom, gruvbox, reference settings/style) ─────────────────────
  programs.waybar = {
    enable = true;
    settings.mainBar = (import ./waybar-settings.nix { }).programs.waybar.settings.mainBar;
    style = (import ./waybar-style.nix { }).programs.waybar.style;
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

  # ── GTK: gruvbox cursor ──────────────────────────────────────────────────
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

  # ── Shell: fish (the default) uses starship; zsh keeps powerlevel10k ─────
  programs.starship = {
    enable = lib.mkForce true;
    enableZshIntegration = lib.mkForce false;
  };
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
