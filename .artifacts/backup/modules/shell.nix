{ config, pkgs, inputs, ... }:
let
  dotfiles = inputs.illogical-impulse-dotfiles;
  # Helper to link files from the .config directory of the repo
  link = path: "${dotfiles}/.config/${path}";
in
{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha"; 
    
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
    
    settings = {
      # Window padding
      window_padding_width = 10;
      # Transparency
      background_opacity = "0.9";
      # Bell
      enable_audio_bell = false;
    };
  };

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
      flake-drybuild = "sudo nixos-rebuild dry-build --flake ~/dotfiles#nixos";
    };
  };

  # ==========================================
  # CONFIG LINKS (Shell Related)
  # ==========================================
  xdg.configFile = {
    "fish/config.fish".source = link "fish/config.fish";
    "fontconfig/fonts.conf".source = link "fontconfig/fonts.conf";
    "foot".source = link "foot";
    "fuzzel".source = link "fuzzel";
    "kitty".source = link "kitty";
    "zshrc.d".source = link "zshrc.d";
    "starship.toml".source = link "starship.toml";
  };
}
