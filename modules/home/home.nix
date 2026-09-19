{
  config,
  variables,
  lib,
  ...
}:
let
  # Desktop variants that carry the Hyprland userland (shared + per-variant rice).
  hyprlandVariants = [
    "nixy"
    "heinz"
    "frost"
  ];
  isHyprland = builtins.elem variables.ui hyprlandVariants;
in
{
  imports =
    [
      ./core.nix
      ./env.nix
      ./fish.nix
      ./packages.nix
      ./obsidian.nix
      ./opencode.nix
      ./gmail-mcp.nix
      ./firecrawl.nix
    ]
    ++ (lib.optionals isHyprland [
      ../../ui/shared/home-shared.nix
      ../../ui/shared/hyprland-home.nix
      ../../ui/${variables.ui}/rice.nix
    ]);

  xdg.configFile."mangal/mangal.toml".text = ''
    [downloader]
    path = "${config.home.homeDirectory}/manga"
    create_manga_dir = true

    [formats]
    use = "pdf"

    [mangadex]
    language = "en"
    nsfw = false
  '';
}