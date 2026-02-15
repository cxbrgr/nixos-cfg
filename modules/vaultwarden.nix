{
  ...
}:

{
  services.vaultwarden = {
    enable = true;
    backupDir = "/data/backup/vaultwarden";
    config = {
      DOMAIN = "https://vault.cxbrgr.com";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      INVITATIONS_ALLOWED = false;
    };

    environmentFile = "/var/lib/vaultwarden/vaultwarden.env";
  };
}
