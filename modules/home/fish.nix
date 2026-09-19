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
      rebuild-nixos = "sudo nixos-rebuild switch --flake /etc/nixos#(hostname)";
      update-nixos = "sudo nix flake update /etc/nixos";
      check = "sudo nix flake check /etc/nixos";
      search = "nix search nixpkgs";
      display = "chafa -f kitty --fit-width";
      clock = "clock-rs -c bright-black -B -b";
      edot = "cd /etc/nixos && nixvim";
      dot = "cd /etc/nixos";
      ga = "git -C /etc/nixos add .";
      op = "opencode";
      yt = "/etc/nixos/scripts/download-vid.sh";
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
          sed -i 's/^  ui = .*;$/  ui = "'$argv[1]'";/' /etc/nixos/variables.nix
          sudo nixos-rebuild switch --flake /etc/nixos#(hostname)
        '';
      };
    };
  };
}