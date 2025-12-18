{
  description = "chr-ber's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
          
          # Home Manager Module
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            
            home-manager.users.chrisleebear = {
              imports = [ ./home/home.nix ];
            };

            # Pass inputs to home-manager
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}