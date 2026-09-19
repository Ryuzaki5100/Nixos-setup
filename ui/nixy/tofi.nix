# tofi ported from anotherhadi/nixy (home/system/tofi/default.nix).
{ lib, ... }:
let
  t = import ./theme.nix;
  c = t.colors;
  rounding =
    if t.rounding > t.barHeight / 2
    then t.barHeight / 2
    else t.rounding;
in
{
  programs.tofi = {
    enable = true;
    settings = {
      anchor = "top";
      height = t.barHeight;
      margin-top = t.gapsOut;
      margin-left = 350;
      margin-right = 350;

      horizontal = true;
      num-results = 8;
      result-spacing = 20;
      padding-top = 2;
      padding-bottom = 2;
      padding-left = 14;
      padding-right = 14;

      font = lib.mkForce t.fonts.sansSerif;
      prompt-color = lib.mkForce "#${c.base0D}ff";
      selection-color = lib.mkForce "#${c.base0D}ff";

      outline-width = 0;
      border-width = 0;
      corner-radius = rounding;

      prompt-text = "  ";
      placeholder-text = "Search...";

      drun-launch = true;
    };
  };
}
