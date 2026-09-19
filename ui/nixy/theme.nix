# Nixy theme data (upstream `themes/nixy.nix` + `config.theme` defaults).
# Upstream uses stylix; here the same base16 palette and metrics are inlined.
{
  colors = {
    base00 = "0A0A0C"; # Default Background
    base01 = "110F12"; # Lighter Background (status bars)
    base02 = "2D2A36"; # Selection Background
    base03 = "514D63"; # Comments, Invisibles
    base04 = "8E8AA0"; # Dark Foreground
    base05 = "C2BED6"; # Default Foreground
    base06 = "D8D5EA"; # Light Foreground
    base07 = "EAE7F7"; # Light Background
    base08 = "E07080"; # red
    base09 = "D49070"; # orange
    base0A = "C4B060"; # yellow
    base0B = "80B880"; # green
    base0C = "70B8C0"; # cyan
    base0D = "9E97F8"; # accent (violet)
    base0E = "C090E8"; # purple
    base0F = "D080A0";
  };

  fonts = {
    monospace = "Maple Mono NF";
    sansSerif = "Rubik";
  };

  # config.theme defaults
  rounding = 20;
  barHeight = 36;
  gapsIn = 8;
  gapsOut = 16;
  activeOpacity = 0.96;
  inactiveOpacity = 0.92;
  blur = false;
  borderSize = 2;
  animationDuration = "0.5"; # "very-fast"
}
