{ ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      if test -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end

      set -gx EDITOR nixvim-editor

      bind ctrl-space accept-autosuggestion
      bind alt-space  accept-autosuggestion
      bind ₹          accept-autosuggestion
      bind shift-tab  accept-autosuggestion
    '';

    shellAliases = {
      nixvim = "nix run github:Ryuzaki5100/nixvim --refresh";
      rebuild-nixos = "sudo nixos-rebuild switch --flake $HOME/Nixos-setup#(hostname)";
      update-nixos = "sudo nix flake update $HOME/Nixos-setup";
      check = "sudo nix flake check $HOME/Nixos-setup";
      search = "nix search nixpkgs";
      display = "chafa -f kitty --fit-width";
      clock = "clock-rs -c bright-black -B -b";
      edot = "cd $HOME/Nixos-setup && nixvim";
      dot = "cd $HOME/Nixos-setup";
      ga = "git -C $HOME/Nixos-setup add .";
      op = "opencode";
      yt = "$HOME/Nixos-setup/scripts/download-vid.sh";
      flash = ".~/Nixos-setup/scripts/flash-iso.sh";
    };

    functions = {
      generate-ssh-key = {
        body = ''
          read -P "Enter your email: " email
          ssh-keygen -t ed25519 -C "$email"
        '';
      };

      # Switch the desktop UI variant by editing variables.nix, then rebuild.
      set-ui = {
        description = "Change the desktop variant and rebuild (usage: set-ui gnome|nixy|heinz|frost)";
        body = ''
          if test (count $argv) -ne 1
              echo "usage: set-ui <gnome|nixy|heinz|frost>"
              return 1
          end
          sed -i 's/^  ui = .*;$/  ui = "'$argv[1]'";/' $HOME/Nixos-setup/variables.nix
          sudo nixos-rebuild switch --flake $HOME/Nixos-setup#(hostname)
        '';
      };
    };
  };
}
