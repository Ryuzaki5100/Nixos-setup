# GNOME desktop variant — the current stock desktop.
{ ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}