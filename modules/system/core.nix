# Core, UI-agnostic system configuration: networking, locale, sound,
# bootloader, kernel, printer support.
{
  config,
  pkgs,
  variables,
  ...
}:

{
  # Hostname from variables.nix.
  networking.hostName = variables.hostname;
  networking.networkmanager.enable = true;

  # Bootloader (EFI + systemd-boot).
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Do not change this after installation.
  system.stateVersion = variables.stateVersion;
}