{ pkgs, ... }:

let
  inherit (pkgs) lib;
in
{

  home.packages = with pkgs; [
    # Editors
    neovim
    code-server
    opencode

    # Dev tools
    lazygit
    tmux

    # Containers
    docker
    docker-compose
    jq

    # System info
    fastfetch
    nitch
    btop
    clock-rs
    smartmontools
    exfatprogs

    # Media & graphics
    chafa
    timg
    mpv
    ffmpeg
    yt-dlp
    yazi
    pandoc
    localsend

    # Networking & chat
    browsh
    nchat
    bluetuith
    wifitui
    tailscale
    reddit-tui
    reddix
    discordo
    wiki-tui
    youtube-tui
    smassh
    gemini-cli
    mangal
    # hackernews-tui (not packaged in nixpkgs 26.05 — available on unstable)
    # ani-cli
    # nyaa

    # Obsidian TUIs
    basalt
    pkgs.obsitui
    pkgs.nixvim-editor

    # Utilities
    balena-etcher

    # Fun
    cmatrix
    posting
  ];
}