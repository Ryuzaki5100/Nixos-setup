# Heinz variant rice — faithful port of HeinzDev/Hyprland-dotfiles.
# Hyprland config, waybar, rofi (dracula theme), dunst, kitty (catppuccin),
# alacritty (carbonfox), cava, and the Tokyo Night GTK theme all come straight
# from the upstream dotfiles; each lives in its own module below.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
let
  inherit (import ../shared/wallpapers.nix { inherit pkgs lib; }) heinz heinz-rofi;
in
{
  imports = [
    ./hyprland.nix
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./kitty.nix
    ./alacritty.nix
    ./gtk.nix
    ./scripts.nix
  ];

  home.username = variables.username;

  # ── Packages used by the upstream ricing ─────────────────────────────────
  home.packages = with pkgs; [
    kitty
    alacritty
    rofi
    dunst
    cava
    mpd
    mpc
    ncmpcpp
    blueman
    brightnessctl
    pamixer
    playerctl
    grim
    slurp
    wl-clipboard
    cliphist
    papirus-icon-theme
    cool-retro-term
  ];

  # Upstream keeps wallpapers under ~/Imagens/wallpapers (used by
  # wallpaper_random / default_wall); the rofi theme draws ~/.config/rofi/rofi.png.
  home.file."Imagens/wallpapers/menhera.jpg".source = heinz;
  home.file."Imagens/wallpapers/rofi.png".source = heinz-rofi;
  xdg.configFile."rofi/rofi.png".source = heinz-rofi;

  # Upstream cava configs (config + config1; cava-internal reads config1).
  xdg.configFile."cava/config".source = ./cava/config;
  xdg.configFile."cava/config1".source = ./cava/config1;

  # ── Lock: hyprlock ───────────────────────────────────────────────────────
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
}
