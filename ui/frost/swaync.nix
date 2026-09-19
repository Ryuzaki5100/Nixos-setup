# swaync ported from Frost-Phoenix/nixos-config (modules/home/swaync/swaync.nix).
{ pkgs, ... }:
{
  home.packages = with pkgs; [ swaynotificationcenter ];

  xdg.configFile."swaync/style.css".source = ./swaync/style.css;
  xdg.configFile."swaync/config.json".source = ./swaync/config.json;
}
