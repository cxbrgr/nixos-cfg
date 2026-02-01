{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom.ollama = {
    enable = lib.mkEnableOption "Enable Ollama LLM inference service";
  };

  config = lib.mkIf config.custom.ollama.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda; # Use NVIDIA GPU package
      host = "0.0.0.0"; # Listen on all interfaces (for hmsrvr access)
      port = 11434; # Default Ollama port
    };

    # Open firewall port for Ollama API
    networking.firewall.allowedTCPPorts = [ 11434 ];
  };
}
