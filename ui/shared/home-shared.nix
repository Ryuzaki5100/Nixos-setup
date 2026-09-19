# Shared Home Manager module for all Hyprland (TUI) variants.
# zsh-first shell with the common CLI. Visual UI config lives per-variant
# in ui/<variant>/rice.nix; common Wayland userland lives in hyprland-home.nix.
{
  pkgs,
  lib,
  variables,
  config,
  ...
}:
{
  # All Hyprland variants use zsh as the interactive shell (matching the
  # reference dotfiles), so the shared fish module is switched off.
  programs.fish.enable = lib.mkForce false;

  # ── Shell: zsh + starship ───────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      append = true;
      save = 10000;
      size = 10000;
    };

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      cd = "z";
      ls = "eza --icons=always --no-quotes";
      tree = "eza --icons=always --tree --no-quotes";
      ll = "eza --icons=always --long --header --git --no-quotes";
      cat = "bat --theme=base16 --color=always --paging=never --tabs=2 --wrap=never --plain";
      mkdir = "mkdir -p";
      grep = "rg --color=auto";
      g = "lazygit";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gs = "git status";
      gd = "git diff";
      rebuild-nixos = "sudo nixos-rebuild switch --flake $HOME/Nixos-setup#(hostname)";
      update-nixos = "sudo nix flake update $HOME/Nixos-setup";
      dot = "cd $HOME/Nixos-setup";
      edot = "cd $HOME/Nixos-setup && nvim";
      op = "opencode";
    };

    initContent = ''
      export PATH="$HOME/.nix-profile/bin:$PATH"
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold purple)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.zoxide.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.gh.enable = true;

  home.sessionVariables = {
    COLORTERM = "truecolor";
    MANPAGER = "bat -l man -p";
    EDITOR = lib.mkForce "nvim";
  };

  # ── CLI tooling shared by every Hyprland variant ────────────────────────
  home.packages = with pkgs; [
    bat
    ripgrep
    htop
    btop
    lazygit
    fzf
    starship
  ];

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  qt.enable = true;
}