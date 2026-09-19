# User account + system-level packages for the primary user.
{
  pkgs,
  variables,
  ...
}:

{
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