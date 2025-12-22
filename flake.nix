{
  description = "chr-ber's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    quickshell = {
      url = "github:quickshell-mirror/quickshell/db1777c20b936a86528c1095cbcb1ebd92801402";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    illogical-impulse-dotfiles = {
      url = "github:end-4/dots-hyprland";
      flake = false;
    };
  };

# 2. OUTPUTS (What to build)
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Hostname: "nixos" (Must match networking.hostName in nixos/configuration.nix)
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        
        modules = [
          # Import your existing hardware/system config
          ./nixos/configuration.nix
          
          # Overlays to expose custom packages
          {
            nixpkgs.overlays = [
              (final: prev: import ./pkgs { pkgs = prev; })
            ];
          }

          # Home Manager Module
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Automatically back up conflicting files during activation
            home-manager.backupFileExtension = "backup";
            
            home-manager.users.chrisleebear = {
              imports = [ 
                ./home/home.nix
                (import ./home/modules/default.nix self inputs.illogical-impulse-dotfiles inputs)
              ];
            };

            # Pass inputs to home-manager
            home-manager.extraSpecialArgs = { 
              inherit inputs; 
              quickshell = inputs.quickshell;
              illogical-impulse-dotfiles = inputs.illogical-impulse-dotfiles;
            };
          }
        ];
      };
    };
  };
}