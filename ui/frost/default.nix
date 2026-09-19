# Frost-style UI variant — Hyprland + waybar + rofi + swaync + nvim + ghostty + zsh.
# Curated adaptation of Frost-Phoenix/nixos-config adapted to this Intel desktop.
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

  # Graphical login manager: SDDM + sddm-astronaut, tinted to the frost
  # (gruvbox) palette and showing the rice wallpaper.
  services.xserver.enable = true; # SDDM's greeter runs on X
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "${wallpapers.frost}";
        BackgroundColor = "#1D2021";
        CropBackground = "true";
        DimBackground = "0.35";
        DimBackgroundColor = "#1D2021";
        Font = "Maple Mono NF";
        FontSize = "14";
        FormBackgroundColor = "#1D2021";
        LoginFieldBackgroundColor = "#282828";
        PasswordFieldBackgroundColor = "#282828";
        LoginFieldTextColor = "#EBDBB2";
        PasswordFieldTextColor = "#EBDBB2";
        PlaceholderTextColor = "#A89984";
        UserIconColor = "#FE8019";
        PasswordIconColor = "#FE8019";
        TimeTextColor = "#EBDBB2";
        DateTextColor = "#FE8019";
        HeaderTextColor = "#EBDBB2";
        HighlightBackgroundColor = "#FE8019";
        HighlightBorderColor = "#FE8019";
        HighlightTextColor = "#1D2021";
        LoginButtonBackgroundColor = "#FE8019";
        LoginButtonTextColor = "#1D2021";
        SessionButtonTextColor = "#EBDBB2";
        SystemButtonsIconsColor = "#EBDBB2";
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