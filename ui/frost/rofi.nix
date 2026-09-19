# rofi ported from Frost-Phoenix/nixos-config (modules/home/rofi/rofi.nix).
{ pkgs, ... }:
{
  home.packages = with pkgs; [ rofi ];

  xdg.configFile."rofi/theme.rasi".source = ./rofi/theme.rasi;
  xdg.configFile."rofi/config.rasi".source = ./rofi/config.rasi;
  xdg.configFile."rofi/powermenu-theme.rasi".source = ./rofi/powermenu-theme.rasi;
}
