{ 
    config,
    pkgs,
    home,
    ...
}:
{
  home.packages = with pkgs; [
    beeper-bridge-manager
  ];

  systemd.user.services.beeper-whatsapp = {
    Unit = {
      Description = "Beeper WhatsApp Bridge";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${pkgs.beeper-bridge-manager}/bin/bbctl run sh-whatsapp";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.beeper-telegram = {
    Unit = {
      Description = "Beeper Telegram Bridge";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${pkgs.beeper-bridge-manager}/bin/bbctl run sh-telegram";
      Restart = "always";
      RestartSec = 10;
      StandardOutput = "journal";
      StandardError = "journal";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}