{ lib, config, pkgs, ... }:

{
  # Import all work-dev modules
  imports = [
    ./wslg.nix
    ./dotnet.nix
    ./databases.nix
    ./gui-apps.nix
    ./terminal.nix
  ];

  # Define convenience profiles for common configurations
  options.work-dev.profiles = with lib; {
    minimal = mkOption {
      type = types.bool;
      default = false;
      description = "Enable minimal work setup (terminal only, no GUI)";
    };

    developer = mkOption {
      type = types.bool;
      default = false;
      description = "Enable full developer setup (all tools including GUI)";
    };

    database-admin = mkOption {
      type = types.bool;
      default = false;
      description = "Enable database administration setup";
    };
  };

  config = lib.mkMerge [
    # Minimal profile: Just terminal and basic tools
    (lib.mkIf config.work-dev.profiles.minimal {
      work-dev.terminal.enable = true;
      work-dev.dotnet.enable = false;
      work-dev.databases.enable = false;
      work-dev.gui-apps.enable = false;
      work-dev.wslg.enable = false;
    })

    # Developer profile: Everything enabled
    (lib.mkIf config.work-dev.profiles.developer {
      work-dev.terminal.enable = lib.mkDefault true;
      work-dev.dotnet.enable = lib.mkDefault true;
      work-dev.databases.enable = lib.mkDefault true;
      work-dev.gui-apps.enable = lib.mkDefault true;
      work-dev.wslg.enable = lib.mkDefault true;
    })

    # Database admin profile: DB tools + GUI
    (lib.mkIf config.work-dev.profiles.database-admin {
      work-dev.terminal.enable = lib.mkDefault true;
      work-dev.dotnet.enable = lib.mkDefault false;
      work-dev.databases.enable = lib.mkDefault true;
      work-dev.gui-apps = {
        enable = lib.mkDefault true;
        jetbrains.rider = lib.mkDefault false;
        jetbrains.datagrip = lib.mkDefault true;
      };
      work-dev.wslg.enable = lib.mkDefault true;
    })
  ];
}
