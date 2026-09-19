# Nixy-style UI variant — Hyprland + waybar + tofi + ghostty + zsh + swaync.
# Curated adaptation of anotherhadi/nixy adapted to this Intel desktop.
{
  pkgs,
  lib,
  variables,
  ...
}:
let
  # Wallpapers shared with the Home Manager rice; the SDDM theme reuses the
  # same image as the desktop background.
  wallpapers = import ../shared/wallpapers.nix { inherit pkgs lib; };
in
{
  # Hyprland Wayland compositor.
  programs.hyprland.enable = true;

  # Wayland hints for Electron/Chromium and Firefox.
  environment.variables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  # PAM for hyprlock.
  security.pam.services.hyprlock = { };

  # Graphical login manager: SDDM + sddm-astronaut, tinted to the nixy
  # (base16 violet) palette and showing the rice wallpaper.
  services.xserver.enable = true; # SDDM's greeter runs on X
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "${wallpapers.nixy}";
        BackgroundColor = "#0A0A0C";
        CropBackground = "true";
        DimBackground = "0.35";
        DimBackgroundColor = "#0A0A0C";
        Font = "Maple Mono NF";
        FontSize = "14";
        FormBackgroundColor = "#0A0A0C";
        LoginFieldBackgroundColor = "#110F12";
        PasswordFieldBackgroundColor = "#110F12";
        LoginFieldTextColor = "#C2BED6";
        PasswordFieldTextColor = "#C2BED6";
        PlaceholderTextColor = "#8E8AA0";
        UserIconColor = "#9E97F8";
        PasswordIconColor = "#9E97F8";
        TimeTextColor = "#EAE7F7";
        DateTextColor = "#C4B060";
        HeaderTextColor = "#EAE7F7";
        HighlightBackgroundColor = "#9E97F8";
        HighlightBorderColor = "#9E97F8";
        HighlightTextColor = "#0A0A0C";
        LoginButtonBackgroundColor = "#9E97F8";
        LoginButtonTextColor = "#0A0A0C";
        SessionButtonTextColor = "#C2BED6";
        SystemButtonsIconsColor = "#C2BED6";
      };
    })
  ];

  # Fonts: Maple Mono NF (UI/terminal glyphs) + Rubik (UI text) + emoji.
  fonts.packages = [
    pkgs.maple-mono.NF
    pkgs.rubik
    pkgs.noto-fonts-color-emoji
  ];

  # XDG desktop portals (hyprland + gtk fallback).
  xdg.portal = {
    enable = true;
    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}