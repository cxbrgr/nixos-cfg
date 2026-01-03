{ pkgs, lib, ... }:
{
    home.packages = with pkgs; [
      # ==========================================
      # Personal Apps - Homeserver Specific
      # ==========================================

      adguardhome       # Network-wide software for blocking ads and tracking
    ];
}