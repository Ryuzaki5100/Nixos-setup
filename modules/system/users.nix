# User account + system-level packages for the primary user.
{
  pkgs,
  variables,
  ...
}:

{
  # NOTE: no `greeter` user is defined here. The login manager (SDDM) creates
  # and manages its own `sddm` system user.
  users.users.${variables.username} = {
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
}