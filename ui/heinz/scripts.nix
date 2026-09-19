# Helper scripts ported from HeinzDev/Hyprland-dotfiles (home/scripts/default.nix).
# The upstream rofi1/rofi2 launch external `launcher.sh` scripts that are not
# part of the repo, so they are pointed at the packaged rofi + heinz theme.
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "cava-internal" ''
      ${pkgs.cava}/bin/cava -p ~/.config/cava/config1 | sed -u 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;'
    '')
    (pkgs.writeShellScriptBin "cool-retro-term-zsh" ''
      exec ${pkgs.cool-retro-term}/bin/cool-retro-term -e zsh
    '')
    (pkgs.writeShellScriptBin "rofi1" ''
      exec ${pkgs.rofi}/bin/rofi -show drun -theme "$HOME/.config/rofi/theme.rasi"
    '')
    (pkgs.writeShellScriptBin "rofi2" ''
      exec ${pkgs.rofi}/bin/rofi -show drun -theme "$HOME/.config/rofi/theme.rasi"
    '')
    (pkgs.writeShellScriptBin "rofiWindow" ''
      exec ${pkgs.rofi}/bin/rofi -show drun -theme "$HOME/.config/rofi/theme.rasi"
    '')
    (pkgs.writeShellScriptBin "wallpaper_random" ''
      if command -v awww >/dev/null 2>&1; then
        killall dynamic_wallpaper 2>/dev/null || true
        awww img "$(find ~/Imagens/wallpapers/. -name '*.png' | shuf -n1)" --transition-type simple
      fi
    '')
    (pkgs.writeShellScriptBin "default_wall" ''
      if command -v awww >/dev/null 2>&1; then
        awww img ~/Imagens/wallpapers/menhera.jpg --transition-type simple
      fi
    '')
  ];
}
