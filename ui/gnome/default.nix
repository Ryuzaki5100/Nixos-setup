# GNOME desktop variant — the current stock desktop.
{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Theme packages referenced by the GNOME dconf profile
  # (org.gnome.desktop.interface: cursor-theme/icons/gtk-theme).
  #
  # These are normally pulled in by the Hyprland rices; without them GNOME
  # cannot resolve the configured `Bibata-Modern-Ice` cursor theme and
  # Wayland renders the pointer as a blank white square.
  environment.systemPackages = with pkgs; [
    bibata-cursors
    papirus-icon-theme
    adw-gtk3
  ];
}
