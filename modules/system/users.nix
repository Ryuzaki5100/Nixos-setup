# User account + system-level packages for the primary user.
{
  pkgs,
  variables,
  ...
}:

{
  # NOT defining users.users.greeter here on purpose: the greetd NixOS module
  # (nixpkgs 26.05, services/misc/greetd.nix) auto-defines it as
  # { isSystemUser = true; group = "greeter"; } when services.greetd.enable.
  # Defining it here too makes BOTH isSystemUser and isNormalUser true ->
  # the XOR assertion in users-groups.nix fires and the whole flake fails.
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