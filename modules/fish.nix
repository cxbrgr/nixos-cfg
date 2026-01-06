{ pkgs, lib, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = "fastfetch";
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first -a";
      cat = "bat";
      hc = "hyprctl";
      ii-c = "xdg-open ~/.config/illogical-impulse/config.json";
      ii-k = "xdg-open ~/.config/hypr/custom/keybinds.conf ";
      flake-rebuild = "sudo nixos-rebuild switch --flake ~/nixos-cfg#wrkstn";
      flake-drybuild = "nixos-rebuild dry-build --flake ~/nixos-cfg#wrkstn";
      flake-eval = "nix eval --raw ~/nixos-cfg#homeConfigurations.wrkstn.activationPackage";
      flake-eval-verbose = "nix eval --json ~/nixos-cfg#nixosConfigurations.wrkstn.config.home-manager.users.chrisleebear.home.packages --apply 'pkgs: map (p: p.name) pkgs' | jq -r '.[]' | sort | uniq";
      flake-list-home-pkgs = "nix eval --json ~/nixos-cfg#homeConfigurations.wrkstn.config.home.packages --apply 'pkgs: map (p: p.name) pkgs' | nix run nixpkgs#jq -- -r '.[]' | sort";
      hypr-logout = "hyprctl dispatch exit";
    };
  };
}