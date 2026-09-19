# Heinz-style UI variant — Hyprland + kitty/alacritty + rofi + dunst + waybar + zsh.
# Curated adaptation of HeinzDev/Hyprland-dotfiles adapted to this Intel desktop.
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

  # Graphical login manager: SDDM + sddm-astronaut, tinted to the heinz
  # (Nightfox Dusk) palette and showing the rice wallpaper.
  services.xserver.enable = true; # SDDM's greeter runs on X
  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        Background = "${wallpapers.heinz}";
        BackgroundColor = "#1E1F29";
        CropBackground = "true";
        DimBackground = "0.35";
        DimBackgroundColor = "#1E1F29";
        Font = "JetBrainsMono Nerd Font";
        FontSize = "14";
        FormBackgroundColor = "#1E1F29";
        LoginFieldBackgroundColor = "#282A36";
        PasswordFieldBackgroundColor = "#282A36";
        LoginFieldTextColor = "#F4F4F9";
        PasswordFieldTextColor = "#F4F4F9";
        PlaceholderTextColor = "#9A9FB8";
        UserIconColor = "#33CCFF";
        PasswordIconColor = "#33CCFF";
        TimeTextColor = "#F4F4F9";
        DateTextColor = "#33CCFF";
        HeaderTextColor = "#F4F4F9";
        HighlightBackgroundColor = "#33CCFF";
        HighlightBorderColor = "#33CCFF";
        HighlightTextColor = "#1E1F29";
        LoginButtonBackgroundColor = "#33CCFF";
        LoginButtonTextColor = "#1E1F29";
        SessionButtonTextColor = "#F4F4F9";
        SystemButtonsIconsColor = "#F4F4F9";
      };
    })
  ];

  # Fonts: JetBrains Mono Nerd Font (UI glyphs) + Hack (alacritty) + Inter.
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.hack
    pkgs.inter
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