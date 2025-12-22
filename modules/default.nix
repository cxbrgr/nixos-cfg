self: illogical-impulse-dotfiles: inputs: {... }:
{
  imports = [
    (import ./options.nix illogical-impulse-dotfiles)
    (import ./quickshell.nix illogical-impulse-dotfiles inputs)
    (import ./hyprland.nix illogical-impulse-dotfiles inputs)
    (import ./packages.nix inputs)
    ./quickshell.nix
    ./zsh.nix
    ./theme.nix
  ];
}