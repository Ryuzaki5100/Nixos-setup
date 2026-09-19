# Central configuration variables for this flake.
#
# Change `ui` below to switch desktop variants — that is the ONLY change
# needed to toggle between different desktop environments:
#
#   ui = "gnome";   # stock GNOME (GDM) — the current desktop
#   ui = "nixy";    # Hyprland + waybar + tofi + ghostty + zsh (anotherhadi/nixy)
#   ui = "heinz";   # Hyprland + kitty + alacritty + rofi + dunst + waybar + zsh (HeinzDev/Hyprland-dotfiles)
#   ui = "frost";   # Hyprland + waybar + rofi + swaync + nvim + ghostty + zsh (Frost-Phoenix/nixos-config)
{
  ui = "nixy";

  username = "ryuzaki";
  hostname = "nixos";
  stateVersion = "26.05";
}
