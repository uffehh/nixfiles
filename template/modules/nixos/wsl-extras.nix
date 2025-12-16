{ lib, config, pkgs, ... }:

# ============================================================================
# WSL Extras Module (NixOS System-Level)
# ============================================================================
#
# This module demonstrates NixOS system-level configuration.
# It adds WSL-specific utilities and system tweaks.
#
# Key differences from Home Manager modules:
# - NixOS modules configure system-wide settings (all users)
# - They can modify systemd services, kernel settings, etc.
# - They require sudo/root privileges to apply
# - They use environment.systemPackages instead of home.packages
#
# ============================================================================

with lib;

let
  cfg = config.mytemplate.wsl-extras;
in
{
  # ==========================================================================
  # OPTIONS - Define what can be configured
  # ==========================================================================

  options.mytemplate.wsl-extras = {
    # Main enable/disable switch
    enable = mkEnableOption "WSL-specific extras and utilities";

    # Whether to disable sleep/suspend (usually desired in WSL)
    disableSleep = mkOption {
      type = types.bool;
      default = true;
      description = "Disable sleep, suspend, and hibernation in WSL";
    };

    # Whether to install WSL utilities
    installUtils = mkOption {
      type = types.bool;
      default = true;
      description = "Install WSL utilities (wslu package)";
    };
  };

  # ==========================================================================
  # CONFIGURATION - What actually gets installed/configured
  # ==========================================================================

  config = mkIf cfg.enable {
    # ========================================================================
    # System Packages
    # ========================================================================

    # Install WSL utilities if enabled
    # wslu provides commands like:
    # - wslview: Open files/URLs in Windows applications
    # - wslpath: Convert between Windows and Linux paths
    # - wslfetch: System info display for WSL
    environment.systemPackages = mkIf cfg.installUtils [
      pkgs.wslu
    ];

    # ========================================================================
    # Disable Sleep/Suspend (Usually Desired in WSL)
    # ========================================================================

    # WSL doesn't really "suspend" like a physical machine, but systemd
    # might try to suspend at low battery levels or other triggers.
    # This is usually undesirable in WSL, so we disable it.
    systemd.sleep.extraConfig = mkIf cfg.disableSleep ''
      AllowSuspend=no
      AllowHibernation=no
      AllowHybridSleep=no
      AllowSuspendThenHibernate=no
    '';

    # ========================================================================
    # WSL-Specific Hints
    # ========================================================================

    # Add a message to /etc/motd (message of the day)
    # This will be shown when users log in
    environment.etc."motd".text = mkIf cfg.enable ''
      ╔════════════════════════════════════════════════════════════╗
      ║  Welcome to NixOS on WSL!                                  ║
      ║                                                             ║
      ║  WSL Tips:                                                  ║
      ║  • Use 'wslview' to open files in Windows apps             ║
      ║  • Access Windows drives at /mnt/c, /mnt/d, etc.           ║
      ║  • Run 'rebuild' to apply configuration changes            ║
      ║                                                             ║
      ║  Docs: https://nixos.org/manual/nixos/stable/              ║
      ╚════════════════════════════════════════════════════════════╝
    '';

    # ========================================================================
    # Additional WSL Tweaks
    # ========================================================================

    # Improve performance by using a better filesystem for /tmp
    # (Optional, but recommended for WSL)
    boot.tmp.useTmpfs = lib.mkDefault true;

    # Enable automatic store optimization
    # This deduplicates files in /nix/store to save disk space
    nix.settings.auto-optimise-store = lib.mkDefault true;
  };
}
