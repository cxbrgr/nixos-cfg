{ pkgs, lib, ... }:
{
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
        flake-update = "~/nixos-cfg/scripts/flake-update.bash";
        flake-rebuild = "sudo nixos-rebuild switch --flake ~/nixos-cfg#wrkstn && hyprctl reload";
        flake-drybuild = "nixos-rebuild dry-build --flake ~/nixos-cfg#wrkstn";
        flake-eval = "nix eval --raw ~/nixos-cfg#homeConfigurations.wrkstn.activationPackage";
        flake-eval-verbose = "nix eval --json ~/nixos-cfg#nixosConfigurations.wrkstn.config.home-manager.users.chrisleebear.home.packages --apply 'pkgs: map (p: p.name) pkgs' | jq -r '.[]' | sort | uniq";
        flake-list-home-pkgs = "nix eval --json ~/nixos-cfg#homeConfigurations.wrkstn.config.home.packages --apply 'pkgs: map (p: p.name) pkgs' | nix run nixpkgs#jq -- -r '.[]' | sort";
        hypr-logout = "hyprctl dispatch exit";
      };

      initContent = ''
        # Use the generated color scheme

        if test -f ~/.cache/ags/user/generated/terminal/sequences.txt; then
            cat ~/.cache/ags/user/generated/terminal/sequences.txt
        fi
      '';
     }; 
}