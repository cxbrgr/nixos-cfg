{ 
  usr,
  inputs,
  ... 
}:
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    # Pass usr and flake inputs to all home-manager modules
    extraSpecialArgs = inputs // { 
      inherit inputs usr; 
    };
  };
}
