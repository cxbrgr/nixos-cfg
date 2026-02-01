{
  ...
}:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # go to nixos-cfg directory if it exists
      if test -d ~/nixos-cfg
        cd ~/nixos-cfg
      end

      # Run fastfetch on new interactive shells
      fastfetch

      # Disable greeting
      set -g fish_greeting

      # Better colors for autosuggestions (Gruvbox-inspired)
      set -g fish_color_autosuggestion 928374
      set -g fish_color_command 98971a
      set -g fish_color_error cc241d --bold
      set -g fish_color_param d79921
      set -g fish_color_quote 689d6a
      set -g fish_color_operator d65d0e
    '';

    shellAliases = {
      # Git abbreviations - expand as you type
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull";
      gst = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gl = "git log --oneline -n 10";

      # Files - eza with icons
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first -a";
      la = "eza -la --icons --group-directories-first";
      lt = "eza --tree --icons --level=2";
      cat = "bat";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Hyprland
      hc = "hyprctl";
      ii-c = "xdg-open ~/.config/illogical-impulse/config.json";
      ii-k = "xdg-open ~/.config/hypr/custom/keybinds.conf";
      hypr-logout = "hyprctl dispatch exit";

      # Safer defaults
      cp = "cp -iv";
      mv = "mv -iv";
      rm = "rm -Iv";

      # Quick access
      cd-nix = "cd ~/nixos-cfg";
    };

    functions = {
      # Create directory and cd into it
      mkcd = "mkdir -p $argv[1] && cd $argv[1]";

      # Quick file search
      ff = "fd --type f --hidden --follow --exclude .git $argv";

      # Quick content search
      rgg = "rg --hidden --follow --glob '!.git' $argv";
    };
  };
}
