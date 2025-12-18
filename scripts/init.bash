#!/bin/bash

# 1. Create the Git Repo Structure
mkdir -p ~/dotfiles/nixos
mkdir -p ~/dotfiles/hypr
mkdir -p ~/dotfiles/waybar

# ==========================================
# SYSTEM (NixOS)
# ==========================================
# Move files to repo (We use sudo because /etc/ is root-owned)
sudo mv /etc/nixos/configuration.nix ~/dotfiles/nixos/
sudo mv /etc/nixos/hardware-configuration.nix ~/dotfiles/nixos/

# Take ownership of them so you can edit in VS Code
sudo chown -R $USER:users ~/dotfiles

# Create Links (Point /etc/ back to your home folder)
sudo ln -s ~/dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix
sudo ln -s ~/dotfiles/nixos/hardware-configuration.nix /etc/nixos/hardware-configuration.nix

# ==========================================
# USER UI (Hyprland)
# ==========================================
# Move files to repo
mv ~/.config/hypr/hyprland.conf ~/dotfiles/hypr/
mv ~/.config/hypr/hyprpaper.conf ~/dotfiles/hypr/

# Create Links
ln -s ~/dotfiles/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln -s ~/dotfiles/hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf

# ==========================================
# TASKBAR (Waybar)
# ==========================================
# Move files to repo
# (If this fails, it means the folder is empty or missing, see note below)
mv ~/.config/waybar/config ~/dotfiles/waybar/
mv ~/.config/waybar/style.css ~/dotfiles/waybar/

# Create Links
ln -s ~/dotfiles/waybar/config ~/.config/waybar/config
ln -s ~/dotfiles/waybar/style.css ~/.config/waybar/style.css

echo "Migration Complete! Your system is now linked to ~/dotfiles"