{ 
  pkgs,
  lib,
  ... 
}:
{
    home.packages = with pkgs; [
      # ==========================================
      # Personal Apps - Homeserver Specific
      # ==========================================
      adguardhome          # Network-wide software for blocking ads and tracking
      nvtopPackages.intel  # GPU monitoring for btop and standalone nvtop
    ];
}