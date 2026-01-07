{ config, pkgs, illogical-flake, nix-flatpak, usr, ... }:

{
  imports = [
    illogical-flake.homeManagerModules.default
    nix-flatpak.homeManagerModules.nix-flatpak
    ../../modules/packages-common.nix
    ../../modules/packages-wrkstn.nix
    ../../modules/git.nix
    ../../modules/zsh.nix
    ../../modules/ghostty.nix
    ../../modules/direnv.nix
    ../../modules/zoxide.nix
    ../../modules/kitty.nix
    ../../modules/atuin.nix
    ../../modules/starship.nix
    ../../modules/fish.nix
    ../../modules/hypr/default.nix
    ../../modules/spotifyd/home.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = usr.name;
  home.homeDirectory = "/home/${usr.name}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    eza           # Color 'ls' with icons
    bat           # Color 'cat' with syntax highlighting
    fd            # Faster 'find'
    ripgrep       # Faster 'grep'
    fastfetch     # The flashy system info tool (replaces neofetch)
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  xdg.configFile = {
    "quickshell/shell.qml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/quickshell/ii/shell.qml";
    "quickshell/qs".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/quickshell/ii";
    "illogical-impulse/translations".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/quickshell/ii/translations";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/chrisleebear/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  # Let Home Manager install and manage itself.
  # Illogical Impulse Configuration
  programs.illogical-impulse = {
    enable = true;
  };

  programs.home-manager.enable = true;
}
