# rofi ported from HeinzDev/Hyprland-dotfiles (home/programs/rofi/default.nix).
{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.cool-retro-term}/bin/cool-retro-term";
  };

  xdg.configFile."rofi/theme.rasi".source = ./rofi-theme.rasi;
}
