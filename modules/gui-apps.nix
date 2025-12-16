{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.work-dev.gui-apps;
in
{
  options.work-dev.gui-apps = {
    enable = mkEnableOption "GUI applications for development";

    jetbrains = {
      rider = mkOption {
        type = types.bool;
        default = true;
        description = "Install JetBrains Rider (.NET IDE)";
      };

      datagrip = mkOption {
        type = types.bool;
        default = true;
        description = "Install JetBrains DataGrip (Database IDE)";
      };
    };

    browsers = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install web browsers for testing";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          firefox
          chromium
        ];
        description = "Browser packages to install";
      };
    };

    vscode = mkOption {
      type = types.bool;
      default = false;
      description = "Install VS Code (if not using Windows version with Remote-WSL)";
    };

    teams = mkOption {
      type = types.bool;
      default = false;
      description = "Install Microsoft Teams (teams-for-linux)";
    };
  };

  config = mkIf cfg.enable {
    # Ensure WSLg is enabled when GUI apps are enabled
    work-dev.wslg.enable = mkDefault true;

    # Allow unfree packages (JetBrains tools are unfree)
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "rider"
      "datagrip"
      "vscode"
    ];

    environment.systemPackages = with pkgs;
      # JetBrains tools
      (optionals cfg.jetbrains.rider [ jetbrains.rider ])
      ++ (optionals cfg.jetbrains.datagrip [ jetbrains.datagrip ])
      # VS Code
      ++ (optionals cfg.vscode [ vscode ])
      # Microsoft Teams
      ++ (optionals cfg.teams [ teams-for-linux ])
      # Web browsers
      ++ (optionals cfg.browsers.enable cfg.browsers.packages);

    # JetBrains tools configuration
    environment.sessionVariables = {
      # Improve JetBrains IDE performance in WSLg
      # Use server-side decorations for better window management
      _JAVA_AWT_WM_NONREPARENTING = "1";
    } // optionalAttrs (cfg.jetbrains.rider || cfg.jetbrains.datagrip) {
      # Use JetBrains Runtime's built-in features
      JETBRAINS_RUNTIME_ARGS = "-Dsun.java2d.uiScale.enabled=true -Dawt.toolkit.name=WLToolkit";
    };

    # Shell aliases for launching apps
    environment.shellAliases =
      optionalAttrs cfg.jetbrains.rider { rider = "rider &>/dev/null &"; }
      // optionalAttrs cfg.jetbrains.datagrip { datagrip = "datagrip &>/dev/null &"; }
      // optionalAttrs cfg.vscode { code = "code &>/dev/null &"; }
      // optionalAttrs cfg.teams { teams = "teams-for-linux &>/dev/null &"; };

    # Desktop entries for better integration
    # WSLg automatically picks these up from /usr/share/applications
    environment.pathsToLink = [ "/share/applications" ];
  };
}
