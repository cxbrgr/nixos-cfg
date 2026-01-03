{ pkgs, lib, ... }:
{
    home.packages = with pkgs; [
      # ==========================================
      # Personal Apps - Workstation Specific
      # ==========================================

# -- Media / Office / Social --
      spotify           # Proprietary music streaming service
      discord           # All-in-one voice and text chat for gamers
      obsidian          # Knowledge base that operates on local Markdown files

      # Browsers
      # no nix pacakge available - thorium          # Chromium fork compiled with AVX optimizations for maximum speed
      nyxt              # Infinite extensibility via Common Lisp; the "Emacs of browsers"
      vivaldi           # Power-user GUI with built-in vertical tabs, split-screen, and gestures
      qutebrowser       # Keyboard-driven minimalism with Vim-like bindings (QtWebEngine backend)
    ];
}