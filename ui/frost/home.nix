# Frost variant: Hyprland + ghostty + rofi + swaync + waybar + zsh.
# Thin wrapper — heavy shared config lives in ui/shared/*.
{ pkgs, lib, variables, config, ... }:
{
  imports = [
    ../shared/home-shared.nix
    ../shared/hyprland-home.nix
  ];

  home.packages = with pkgs; [
    ghostty
    rofi
  ];
}
