{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.work-dev.terminal;
in
{
  options.work-dev.terminal = {
    enable = mkEnableOption "Work-specific terminal tools and configuration";

    gitConfig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable work-specific Git configuration";
      };

      userName = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Git user name for work commits";
      };

      userEmail = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Git user email for work commits";
      };
    };

    tools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable common development tools";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; mkIf cfg.tools.enable [
      # Version control
      git
      git-lfs
      gh  # GitHub CLI
      delta  # Better git diff

      # File operations
      ripgrep
      fd
      eza  # Modern ls
      bat  # Better cat
      tree

      # Text processing
      jq
      yq-go
      sd  # Modern sed

      # Network tools
      curl
      wget
      httpie  # User-friendly HTTP client

      # Build tools
      gnumake
      cmake

      # Container tools (for local dev/testing)
      docker-client
      docker-compose

      # Misc utilities
      unzip
      zip
      p7zip
      file
      htop
      ncdu  # Disk usage analyzer
      tmux
    ];

    # Git configuration (system-wide defaults, users can override)
    programs.git = mkIf cfg.gitConfig.enable {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = false;
        core.editor = "nvim";
        core.autocrlf = "input";  # Important for Windows/WSL line endings
        diff.tool = "nvimdiff";
        merge.tool = "nvimdiff";
        # Use delta for better diffs
        core.pager = "${pkgs.delta}/bin/delta";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";
        delta = {
          navigate = true;
          light = false;
          line-numbers = true;
          side-by-side = false;
        };
      };
    };

    # Shell aliases for common work tasks
    environment.shellAliases = {
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate";

      # Modern replacements
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      cat = "bat";

      # Docker shortcuts
      dc = "docker-compose";
      dps = "docker ps";
      dimg = "docker images";

      # .NET shortcuts (if dotnet is enabled)
      dn = "dotnet";
      dnb = "dotnet build";
      dnr = "dotnet run";
      dnt = "dotnet test";
      dnw = "dotnet watch";

      # Common directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
    };

    # Environment variables for development
    environment.sessionVariables = {
      # Set editor
      EDITOR = "nvim";
      VISUAL = "nvim";

      # Better less behavior
      LESS = "-R";
      LESSHISTFILE = "-";

      # ripgrep config
      RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc";
    };
  };
}
