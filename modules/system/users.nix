# User account + system-level packages for the primary user.
{
  pkgs,
  variables,
  ...
}:

{
  # NOTE: no `greeter` user is defined here. The greetd NixOS module
  # auto-defines it as { isSystemUser = true; group = "greeter"; } when
  # services.greetd.enable; defining it here too trips the
  # isSystemUser/isNormalUser XOR assertion in users-groups.nix.
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