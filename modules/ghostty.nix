{
  pkgs,
  lib,
  ...
}:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Shell - use Fish
      command = "fish";

      # Window
      window-padding-x = 14;
      window-padding-y = 14;

      # Can only use either one of those options
      background-opacity = 0.90;
      #background-blur = 30;

      window-decoration = "none";

      # Font
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      adjust-cell-height = "15%";

      # Theme
      theme = "Catppuccin Mocha";
      minimum-contrast = 1.1;

      # Cursor
      cursor-style = "bar";
      cursor-style-blink = true;

      # Scrollback
      scrollback-limit = 10000;

      # Clipboard
      copy-on-select = true;

      # URLs
      link-url = true;

      # Performance
      gtk-single-instance = true;

      keybind = [
        "ctrl+k=reset"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
      ];
    };
  };
}
