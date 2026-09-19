# GTK / icon / cursor theme from HeinzDev/Hyprland-dotfiles (home/themes).
{ pkgs, lib, ... }:
{
  gtk = {
    enable = true;

    # Upstream themes.nix: Tokyo Night GTK + Yaru-magenta icons + Bibata cursor.
    iconTheme = lib.mkForce {
      name = "Yaru-magenta-dark";
      package = pkgs.yaru-theme;
    };
    theme = lib.mkForce {
      name = "Tokyonight-Dark-B-LB";
      package = pkgs.tokyonight-gtk-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/shell/extensions/user-theme" = {
      name = "Tokyonight-Dark-B-LB";
    };
  };
}
