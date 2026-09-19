{
  config,
  ...
}:
{
  imports = [
    ./core.nix
    ./env.nix
    ./fish.nix
    ./packages.nix
    ./obsidian.nix
    ./opencode.nix
    ./gmail-mcp.nix
    ./firecrawl.nix
  ];

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