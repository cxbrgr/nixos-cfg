{ config, lib, ... }:
let
  enabled = config.illogical-impulse.enable;
in
{
  config = lib.mkIf enabled {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      
      shellAliases = {
        ll = "ls -l";
        c = "clear";
        g = "git";
        gs = "git status";
        flake-update = "~/dotfiles/scripts/flake-update.bash";
        flake-rebuild = "sudo nixos-rebuild switch --flake ~/dotfiles#nixos && hyprctl reload";
        flake-drybuild = "nixos-rebuild dry-build --flake ~/dotfiles#nixos";
        flake-eval = "nix eval --raw ~/dotfiles#homeConfigurations.chrisleebear.activationPackage";
        flake-eval-verbose = "nix eval --json .#nixosConfigurations.nixos.config.home-manager.users.chrisleebear.home.packages --apply 'pkgs: map (p: p.pname or p.name) pkgs' | jq -r '.[]' | sort | uniq";
      };

      initExtra = ''
        # Use the generated color scheme

        if test -f ~/.cache/ags/user/generated/terminal/sequences.txt; then
            cat ~/.cache/ags/user/generated/terminal/sequences.txt
        fi
      '';
     }; 
  };
}