# EXPERIMENTAL
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.custom.autoUpgrade;

  upgradeScript = pkgs.writeShellScript "nixos-upgrade-with-rollback" ''
    set -euo pipefail

    log() { echo "[auto-upgrade] $(date '+%Y-%m-%d %H:%M:%S') $*"; }

    # Record current generation before upgrading
    prev_system=$(readlink /nix/var/nix/profiles/system)
    log "Current system: $prev_system"

    # Attempt the upgrade
    log "Starting upgrade from flake: ${cfg.flake}"
    if nixos-rebuild switch --flake ${cfg.flake} --upgrade; then
      new_system=$(readlink /nix/var/nix/profiles/system)
      log "Upgrade succeeded: $new_system"
      if [ "$prev_system" = "$new_system" ]; then
        log "System unchanged (already up to date)"
      fi
    else
      exit_code=$?
      log "ERROR: Upgrade failed (exit code $exit_code)"
      log "Rolling back to previous system: $prev_system"

      # Roll back by activating the previous system
      if "$prev_system/bin/switch-to-configuration" switch; then
        log "Rollback succeeded"
      else
        log "ERROR: Rollback also failed — system may be in an inconsistent state"
      fi

      ${pkgs.util-linux}/bin/wall \
        "NixOS auto-upgrade failed and was rolled back. Check: journalctl -u nixos-upgrade.service"

      exit "$exit_code"
    fi
  '';
in
{
  options.custom.autoUpgrade = {
    enable = lib.mkEnableOption "automatic NixOS upgrades with rollback on failure";

    flake = lib.mkOption {
      type = lib.types.str;
      default = "github:cxbrgr/nixos-cfg";
      description = "Flake URI to upgrade from.";
    };

    dates = lib.mkOption {
      type = lib.types.str;
      default = "04:00";
      description = "Schedule for upgrades in systemd.time(7) format.";
    };

    allowReboot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to allow automatic reboots when the kernel or initrd changes.";
    };

    rebootWindow = lib.mkOption {
      type = lib.types.attrs;
      default = {
        lower = "02:00";
        upper = "06:00";
      };
      description = "Time window during which reboots are permitted.";
    };

    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "45min";
      description = "Random delay before upgrade starts to avoid thundering herd.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Use the built-in auto-upgrade for scheduling (timer, reboot logic)
    system.autoUpgrade = {
      enable = true;
      flake = cfg.flake;
      dates = cfg.dates;
      allowReboot = cfg.allowReboot;
      rebootWindow = cfg.rebootWindow;
      randomizedDelaySec = cfg.randomizedDelaySec;
      persistent = true;
    };

    # Override the upgrade service script with our rollback wrapper
    systemd.services.nixos-upgrade = {
      serviceConfig.ExecStart = lib.mkForce upgradeScript;
    };
  };
}
