#!/bin/bash

# Only needed when setting up a fresh system

# 1. Create the Git Repo Structure
mkdir -p ~/dotfiles/nixos
mkdir -p ~/dotfiles/hypr
mkdir -p ~/dotfiles/waybar

# ==========================================
# SYSTEM (NixOS)
# ==========================================
# Remove fils or old links
sudo rm /etc/nixos/configuration.nix
sudo rm /etc/nixos/hardware-configuration.nix

# Create Links (Point /etc/ back to your home folder)
sudo ln -s ~/dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix
sudo ln -s ~/dotfiles/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix

# ==========================================
# USER UI (Hyprland)
# ==========================================
# Remove fils or old links
rm ~/.config/hypr/hyprland.conf
rm ~/.config/hypr/hyprpaper.conf

# Create Links
ln -s ~/dotfiles/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln -s ~/dotfiles/hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf

# ==========================================
# TASKBAR (Waybar)
# ==========================================
# Remove fils or old links
# (If this fails, it means the folder is empty or missing, see note below)
rm ~/.config/waybar/config
rm ~/.config/waybar/style.css

# Create Links
ln -s ~/dotfiles/waybar/config ~/.config/waybar/config
ln -s ~/dotfiles/waybar/style.css ~/.config/waybar/style.css

echo "Migration Complete! Your system is now linked to ~/dotfiles"