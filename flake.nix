{
  description = "chr-ber's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    quickshell = {
      url = "github:quickshell-mirror/quickshell/db1777c20b936a86528c1095cbcb1ebd92801402";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    systems.url = "github:nix-systems/default-linux";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    illogical-impulse-dotfiles = {
      url = "github:end-4/dots-hyprland";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, quickshell, illogical-impulse-dotfiles, systems,... }@ inputs: 
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
    in {
      legacyPackages = eachSystem (system:
        import ./pkgs {
          pkgs = nixpkgs.legacyPackages.${system};
        }
      );

      homeManagerModules.default = import ./modules self illogical-impulse-dotfiles inputs;

      nixosConfigurations = {
        # Hostname must match networking.hostName in nixos/configuration.nix
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs self; };
          
          modules = [
            { nixpkgs.hostPlatform = "x86_64-linux"; }
            ./nixos/configuration.nix
            
            {
              nixpkgs.overlays = [
                (final: prev: import ./pkgs { pkgs = prev; })
              ];
            }

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.chrisleebear = {
                imports = [ self.homeManagerModules.default ];
              };
              home-manager.extraSpecialArgs = { inherit inputs self; };
            }
          ];
        };
      };
    };
}