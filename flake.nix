{
  description = "NixOS configuration — full OS managed from here";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Pinned unstable, exposed to modules as `pkgs.unstable` via overlay.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/b1822af";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake/beta";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      zen-browser,
      ...
    }:
    let
      system = "x86_64-linux";
      variables = import ./variables.nix;

      # Every desktop "variant" is one module under ui/<name>. Switching UIs
      # is just editing `ui` in ./variables.nix and rebuilding.
      uiModules = {
        gnome = ./ui/gnome;
        nixy = ./ui/nixy;
        heinz = ./ui/heinz;
        frost = ./ui/frost;
      };
      uiModule = uiModules.${variables.ui};
    in
    {
      nixosConfigurations.${variables.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit variables zen-browser;
        };

        modules = [
          ./modules/system/core.nix
          ./modules/system/nix.nix
          ./modules/system/users.nix
          ./modules/system/apps.nix
          uiModule
          ./hardware-configuration.nix

          home-manager.nixosModules.home-manager

          {
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };

                # Custom packages, shared with the Home Manager config.
                obsitui = prev.callPackage ./pkgs/obsitui.nix { };
                nixvim-editor = prev.callPackage ./pkgs/nixvim-editor.nix { };
                gmail-mcp-auth = prev.callPackage ./pkgs/gmail-mcp-auth.nix { };
              })
            ];
          }

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = {
              inherit variables;
            };
            home-manager.users.${variables.username}.imports = [
              ./modules/home/home.nix
            ];
          }
        ];
      };
    };
}