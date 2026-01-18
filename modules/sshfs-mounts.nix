{
  pkgs,
  config,
  ...
}:
{
  # SSHFS package for mounting remote filesystems over SSH
  environment.systemPackages = [ pkgs.sshfs ];

  # Allow FUSE mounts by regular users
  programs.fuse.userAllowOther = true;

  # Create mount point directory
  systemd.tmpfiles.rules = [
    "d /mnt/hmsrvr/data 0755 chrisleebear users -"
    "d /mnt/rtr/entware 0755 chrisleebear users -"
  ];

  # Mount hmsrvr:/data using SSHFS with automount
  fileSystems."/mnt/hmsrvr/data" = {
    device = "chrisleebear@hmsrvr:/data";
    fsType = "fuse.sshfs";
    options = [
      "noauto"                    # Don't mount at boot
      "x-systemd.automount"       # Mount on first access
      "x-systemd.idle-timeout=60" # Unmount after 60s idle
      "_netdev"                   # Wait for network
      "users"                     # Allow user to mount/unmount
      "allow_other"               # Allow other users to access
      "default_permissions"       # Use local permission checking
      "reconnect"                 # Auto-reconnect on connection loss
      "ServerAliveInterval=15"    # Send keepalive every 15s
      "ServerAliveCountMax=3"     # Disconnect after 3 missed keepalives
      "identityfile=/home/chrisleebear/.ssh/id_hmsrvr"
    ];
  };

  fileSystems."/mnt/rtr/entware" = {
    device = "cxbrgr@rtr:/tmp/mnt/rtr/entware";
    fsType = "fuse.sshfs";
    options = [
      "noauto"                    # Don't mount at boot
      "x-systemd.automount"       # Mount on first access
      "x-systemd.idle-timeout=60" # Unmount after 60s idle
      "_netdev"                   # Wait for network
      "users"                     # Allow user to mount/unmount
      "allow_other"               # Allow other users to access
      "default_permissions"       # Use local permission checking
      "reconnect"                 # Auto-reconnect on connection loss
      "ServerAliveInterval=15"    # Send keepalive every 15s
      "ServerAliveCountMax=3"     # Disconnect after 3 missed keepalives
      "uid=1000"                  # Makes remote files appear owned by chrisleebear locally
      "gid=100"                   # Makes remote files appear owned by 'users' group locally
      "StrictHostKeyChecking=accept-new" # Accept new host keys
      "identityfile=/home/chrisleebear/.ssh/id_rtr"
      "UserKnownHostsFile=/home/chrisleebear/.ssh/known_hosts"
    ];
  };

  networking.hosts = {
    "10.10.10.10" = [ "hmsrvr" ];
    "10.10.10.1" = [ "rtr" ];
  };
}
