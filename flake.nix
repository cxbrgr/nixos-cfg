{
  description = "chr-ber's nixos hosts configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles-fork = {
      url = "git+file:sources/chr-ber-dots-hyprland?submodules=1";
      flake = false;
    };

    illogical-flake = {
      url = "github:soymou/illogical-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dotfiles.follows = "dotfiles-fork";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
  };

  outputs = 
  { 
    self,
    nixpkgs,
    home-manager,
    illogical-flake,
    ... 
  }@inputs: 
  let
    system = "x86_64-linux";
    usr = {
      name = "chrisleebear";
      fullName = "Chris";
    };
  in
  {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

    nixosConfigurations.wrkstn = nixpkgs.lib.nixosSystem {
      specialArgs = inputs // {
        inherit usr;
      };      
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/wrkstn/configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };

    nixosConfigurations.hmsrvr = nixpkgs.lib.nixosSystem {
      specialArgs = inputs // {
        inherit usr;
      };
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/hmsrvr/configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
