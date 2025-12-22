#!/usr/bin/env bash

# Flake Update Script
# This script updates the NixOS system using flakes.
# It updates the flake inputs, rebuilds the system, and 
# commits the changes.

# 1. Stop script immediately on error
set -e

# 2. Go to your config directory
cd ~/dotfiles || exit

# 3. Ask for sudo password upfront (and keep it alive)
echo "🔒 Authenticating..."
sudo -v

# 4. Update the Lockfile (Find new package versions)
echo "📦 Updating Flake inputs..."
nix flake update

# 5. Rebuild the System
echo "🛠️  Rebuilding NixOS..."
# We use 'sudo' here, but it uses the cached credential from step 3
sudo nixos-rebuild switch --flake .#nixos

# 6. (Optional) Commit the change to Git so you can roll back later
echo "💾 Committing changes..."
git commit -am "System Update $(date +%Y-%m-%d)"
git push origin main

echo "✅ Upgrade Complete!"