{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.illogical-flake.homeManagerModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ../../modules/packages-common.nix
    ../../modules/packages-wrkstn.nix
    ../../modules/git.nix
    ../../modules/zsh.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "chrisleebear";
  home.homeDirectory = "/home/chrisleebear";

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
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
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

    # TODO: fix quickshell crash on nixos rebuild
    "hypr/custom/env.conf".text = ''
      env = qsConfig,ii
    '';

    "hypr/custom/rules.conf".text = ''
      monitor = DP-4, 3440x1440@100, 0x0, 1
      monitor = HDMI-A-2, 2560x1440@75, 3440x0, 1

      workspace = 1, monitor:DP-4
      workspace = 2, monitor:DP-4

      workspace = 5, monitor:DP-4
      workspace = 6, monitor:DP-4

      workspace = 9, monitor:DP-4
      workspace = 10, monitor:DP-4

      workspace = 3, monitor:HDMI-A-2
      workspace = 4, monitor:HDMI-A-2

      workspace = 7, monitor:HDMI-A-2
      workspace = 8, monitor:HDMI-A-2
    '';

    "hypr/custom/general.conf".text = ''
      input {
          kb_layout = de
          follow_mouse = 1
          touchpad {
              natural_scroll = no
          }
          sensitivity = 0
      }
    '';

    "hypr/custom/execs.conf".text = ''
      exec-once = [workspace 1 silent] vivaldi
      exec-once = [workspace 4 silent] discord
      exec-once = [workspace 4 silent] kitty btop
      exec-once = [workspace 5 silent] spotify
    '';
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
    dotfiles = {
      fish.enable = true;
      kitty.enable = true;
      starship.enable = true;
    };
  };

  programs.home-manager.enable = true;
}
