{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    illogical-flake = {
      url = "github:soymou/illogical-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, illogical-flake, ... }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.wrkstn = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/wrkstn/configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };

    homeConfigurations.wrkstn = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ 
        ./hosts/wrkstn/home.nix 
        illogical-flake.homeManagerModules.default
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        {
          programs.illogical-impulse = {
              enable = true;
              dotfiles = {
                fish.enable = true;
                kitty.enable = true;
                starship.enable = true;
              };
            };        
          }
      ];
      extraSpecialArgs = {inherit inputs;};
    };

    nixosConfigurations.hmsrvr = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./hosts/hmsrvr/configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };

    homeConfigurations.hmsrvr = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ 
        ./hosts/hmsrvr/home.nix 
      ];
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
