# Nix daemon configuration: flakes, garbage collection, store optimisation.
{ pkgs, ... }:

{
  # Enable flakes and the modern Nix command.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Weekly garbage collection, keeping the last 7 generations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Historically-valuable automatic optimisations.
  nix.settings.auto-optimise-store = true;
}