{ 
  pkgs,
  lib,
  config,
  ... 
}:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    zplug = {
      enable = true;
      plugins = [
        {
          name = "plugins/git";
          tags = [ "from:oh-my-zsh" ];
        }
        {
          name = "fdellwing/zsh-bat";
          tags = [ "as:command" ];
        }
      ];
    };

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first -a";
      cat = "bat";
      gs = "git status";
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

    initContent = ''
      # Use the generated color scheme

      if test -f ~/.cache/ags/user/generated/terminal/sequences.txt; then
          cat ~/.cache/ags/user/generated/terminal/sequences.txt
      fi
    '';
    }; 
}