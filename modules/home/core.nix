{
  variables,
  ...
}:
{
  home.username = variables.username;
  home.homeDirectory = "/home/${variables.username}";
  home.stateVersion = variables.stateVersion;

  programs.home-manager.enable = true;

  # Match the Rpi-Homemanager behaviour: expose the ~/dotfiles alias for the
  # terminal-centric workflow (this repo is managed at /etc/nixos however).
  home.sessionVariables.REPO = "/etc/nixos";
}