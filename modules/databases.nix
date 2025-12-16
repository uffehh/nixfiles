{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.work-dev.databases;
in
{
  options.work-dev.databases = {
    enable = mkEnableOption "Database clients and tools";

    postgresql = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable PostgreSQL client tools";
      };
    };

    sqlserver = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SQL Server client tools";
      };
    };

    mysql = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable MySQL/MariaDB client tools";
      };
    };

    sqlite = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SQLite tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      # PostgreSQL tools
      (optionals cfg.postgresql.enable [ postgresql pgcli ])
      # SQL Server tools (use DataGrip or DBeaver for SQL Server access)
      ++ (optionals cfg.sqlserver.enable [ unixODBC freetds ])
      # MySQL/MariaDB tools
      ++ (optionals cfg.mysql.enable [ mariadb-client mycli ])
      # SQLite
      ++ (optionals cfg.sqlite.enable [ sqlite sqlitebrowser ])
      # Generic database tools
      ++ [
        dbeaver-bin  # Universal database tool (alternative to DataGrip)
        # Connection and data manipulation
        jq    # JSON processing (for working with JSON columns)
        yq-go # YAML processing
        csvkit # CSV manipulation tools
      ];

    # Shell aliases for database work
    environment.shellAliases =
      optionalAttrs cfg.postgresql.enable { pg = "pgcli"; }
      // optionalAttrs cfg.mysql.enable { my = "mycli"; }
      // optionalAttrs cfg.sqlite.enable { sq = "sqlite3"; }
      // { db = "dbeaver"; };
  };
}
