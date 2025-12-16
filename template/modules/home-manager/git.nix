{ lib, config, pkgs, ... }:

# ============================================================================
# Git Configuration Module
# ============================================================================
#
# This module demonstrates how to create options with parameters.
# It configures Git with your personal information and useful defaults.
#
# Key concepts:
# - mkOption: Define configurable options
# - types.str: String type for options like userName
# - types.attrsOf: Attribute set type for collections like aliases
# - mkIf: Conditional configuration based on enable option
#
# ============================================================================

with lib;

let
  cfg = config.mytemplate.git;
in
{
  # ==========================================================================
  # OPTIONS - Define what can be configured
  # ==========================================================================

  options.mytemplate.git = {
    # Main enable/disable switch
    enable = mkEnableOption "custom git configuration";

    # User name for commits
    userName = mkOption {
      type = types.str;
      default = "Your Name";
      description = "Name to use for git commits";
      example = "Jane Doe";
    };

    # User email for commits
    userEmail = mkOption {
      type = types.str;
      default = "you@example.com";
      description = "Email to use for git commits";
      example = "jane.doe@company.com";
    };

    # Additional git aliases (merged with defaults)
    extraAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional git aliases to add";
      example = literalExpression ''
        {
          pushf = "push --force-with-lease";
          amend = "commit --amend --no-edit";
        }
      '';
    };

    # Additional git ignore patterns
    extraIgnores = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional global git ignore patterns";
      example = [ "*.local" ".env.local" ];
    };
  };

  # ==========================================================================
  # CONFIGURATION - What actually gets installed/configured
  # ==========================================================================

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      # User information (from options above)
      userName = cfg.userName;
      userEmail = cfg.userEmail;

      # ======================================================================
      # Git Aliases - Shortcuts for Common Commands
      # ======================================================================

      aliases = {
        # === Basic Shortcuts ===
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";

        # === Pretty Log ===
        # Shows a nice graph of your commit history
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";

        # === Useful Commands ===
        last = "log -1 HEAD --stat";              # Show what changed in last commit
        undo = "reset HEAD~1 --mixed";            # Undo last commit but keep changes
        unstage = "reset HEAD --";                # Unstage files
        uncommit = "reset --soft HEAD~1";         # Undo commit but keep changes staged

        # === Branch Management ===
        branches = "branch -a";                   # List all branches
        recent = "branch --sort=-committerdate";  # List branches by recent activity

        # === Diff Shortcuts ===
        df = "diff";
        dc = "diff --cached";                     # Show staged changes

      } // cfg.extraAliases;  # Merge user's custom aliases

      # ======================================================================
      # Git Configuration
      # ======================================================================

      extraConfig = {
        # === Basic Settings ===
        init.defaultBranch = "main";              # Use 'main' instead of 'master'
        pull.rebase = false;                      # Use merge instead of rebase on pull

        # === Editor ===
        core.editor = "vim";                      # Default editor for commit messages

        # === Line Endings (Important for WSL!) ===
        core.autocrlf = "input";                  # Convert CRLF to LF on commit

        # === Better Diffs with Delta ===
        core.pager = "${pkgs.delta}/bin/delta";
        interactive.diffFilter = "${pkgs.delta}/bin/delta --color-only";

        delta = {
          navigate = true;                        # Use n/N to jump between files
          light = false;                          # Use dark theme
          line-numbers = true;                    # Show line numbers
          side-by-side = false;                   # Vertical diff (change to true for horizontal)
        };

        # === Merge/Diff Tools ===
        diff.tool = "vimdiff";
        merge.tool = "vimdiff";
        merge.conflictstyle = "diff3";            # Show original code in conflicts

        # === Push Settings ===
        push.default = "simple";                  # Only push current branch
        push.autoSetupRemote = true;              # Automatically set up remote branch

        # === Color Settings ===
        color.ui = "auto";                        # Colorize output

        # === Helpful Features ===
        help.autocorrect = 1;                     # Autocorrect typos after 0.1 seconds
        rerere.enabled = true;                    # Remember how you resolved conflicts
      };

      # ======================================================================
      # Global Git Ignore Patterns
      # ======================================================================

      ignores = [
        # === Editor/IDE Files ===
        "*~"              # Vim swap files
        "*.swp"           # Vim swap files
        "*.swo"           # Vim swap files
        ".idea/"          # IntelliJ IDEA
        ".vscode/"        # Visual Studio Code
        "*.code-workspace"

        # === OS Files ===
        ".DS_Store"       # macOS Finder
        "Thumbs.db"       # Windows
        "desktop.ini"     # Windows

        # === Build Artifacts ===
        "*.log"           # Log files
        "*.tmp"           # Temporary files
        ".cache/"         # Cache directories

        # === Development ===
        ".env"            # Environment files (might contain secrets!)
        ".env.local"      # Local environment overrides
        "node_modules/"   # Node.js dependencies (can be huge!)
      ] ++ cfg.extraIgnores;  # Merge user's custom ignores
    };
  };
}
