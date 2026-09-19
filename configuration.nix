# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page and
# https://search.nixos.org/options

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable flakes and the modern Nix command.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";

  # Enable networking.
  networking.networkmanager.enable = true;

  # Time zone.
  time.timeZone = "Asia/Kolkata";

  # Locale.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # GNOME.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Keyboard.
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing.
  services.printing.enable = true;

  # Sound / PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account.
  users.users."ryuzaki" = {
    isNormalUser = true;
    description = "ryuzaki";

    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    packages = with pkgs; [
      git
      unstable.opencode
    ];
  };

  # Firefox.
  programs.firefox.enable = true;

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Do not change this after installation.
  system.stateVersion = "26.05";
}
