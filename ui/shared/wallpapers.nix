# Wallpaper store paths shared by the Hyprland variants.
# Each derivation is a pkgs.fetchurl straight from the reference repos,
# so per-variant rices can point their wallpaper daemon at a store path.
{
  pkgs,
  lib,
  ...
}:
let
  gh = owner: repo: path: sha256:
    pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/${owner}/${repo}/main/${path}";
      sha256 = sha256;
      name = lib.strings.sanitizeDerivationName (builtins.baseNameOf path);
    };
in
{
  # Nixy (anotherhadi/awesome-wallpapers)
  nixy = gh "anotherhadi" "awesome-wallpapers" "wallpapers/another-one.png" "10kjdlcxdh9j2rn6srf5svg0cnamf576vjr73mqs7skk2gqixabc";

  # Heinz (HeinzDev/Hyprland-dotfiles)
  heinz = gh "HeinzDev" "Hyprland-dotfiles" "home/wallpapers/menhera.jpg" "17vghcy8mx9vbny6vq4crmk1nglwznlrdq5mh8zc3i9p4zzghhx5";
  heinz-rofi = gh "HeinzDev" "Hyprland-dotfiles" "home/wallpapers/rofi.png" "1gdvc7ykp9zw0nl5nfh4na7slhzj9kxdn8qz1rac3cvjxaikw71b";

  # Frost (Frost-Phoenix/nixos-config, gruvbox)
  frost = gh "Frost-Phoenix" "nixos-config" "wallpapers/otherWallpaper/gruvbox/japanese_pedestrian_street.png" "1j5770hbxkizs7a48qf43lhykgp0p0dyhyfkmyljyfyqcfgcfbw7";
  frost-hyprlock = gh "Frost-Phoenix" "nixos-config" "wallpapers/otherWallpaper/gruvbox/forest_road.jpg" "sha256-VXiR77ElDBLM2UzZP/VkjseWnFUVOBLZtdkWkotv2u0=";
}