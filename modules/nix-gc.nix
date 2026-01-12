{ ... }:
{
  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 90d --keep 5";
  };

  # Optimize store automatically
  nix.settings.auto-optimise-store = true;
}
