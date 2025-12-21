{ lib, config, pkgs, ... }:

# ============================================================================
# Shell Configuration Module
# ============================================================================
#
# This module demonstrates how to create a Home Manager module with options.
# It configures your shell environment with modern tools and a nice prompt.
#
# Learn more about Home Manager modules:
# https://nix-community.github.io/home-manager/index.html#sec-writing-modules
#
# ============================================================================

with lib;

let
  cfg = config.mytemplate.shell;
in
{
  # ==========================================================================
  # OPTIONS - Define what can be configured
  # ==========================================================================

  options.mytemplate.shell = {
    # Main enable/disable switch for this module
    enable = mkEnableOption "custom shell configuration with modern tools";

    # Custom shell aliases (users can add their own)
    extraAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Additional shell aliases to add";
      example = literalExpression ''
        {
          myproject = "cd ~/projects/my-project";
          deploy = "npm run deploy";
        }
      '';
    };

    # Whether to enable fun packages
    funPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Install fun terminal packages (neofetch, fortune, cowsay, lolcat)";
    };
  };

  # ==========================================================================
  # CONFIGURATION - What actually gets installed/configured
  # ==========================================================================

  config = mkIf cfg.enable {
    # ========================================================================
    # Packages
    # ========================================================================

    home.packages = with pkgs; [
      # Modern CLI tools (better replacements for traditional commands)
      fzf             # Fuzzy finder - Ctrl+R for history, Ctrl+T for files
      zoxide          # Smarter cd - learns your habits
      tldr            # Simplified man pages

      # Fun packages (if enabled)
    ] ++ lib.optionals cfg.funPackages [
      neofetch        # System info display
      fortune         # Random quotes
      cowsay          # ASCII cow says things
      lolcat          # Rainbow text
    ];

    # ========================================================================
    # Bash Configuration
    # ========================================================================

    programs.bash = {
      enable = true;

      # Initialize tools in bash
      initExtra = ''
        # Initialize starship prompt (makes your prompt beautiful!)
        eval "$(starship init bash)"

        # Initialize zoxide (smarter cd command)
        # Usage: Use 'z' instead of 'cd' (e.g., 'z documents')
        eval "$(zoxide init bash)"

        # Welcome message
        echo "Welcome to NixOS WSL! Type 'rebuild' (or 'nh os switch --ask') to rebuild your system."
      '';

      # Shell aliases (shortcuts for common commands)
      shellAliases = {
        # === System Management ===
        rebuild = "nh os switch --ask";          # Rebuild NixOS
        edit-config = "cd /etc/nixos && vim configuration.nix";  # Edit config
        find-todos = "grep -rn 'TODO' /etc/nixos --color=always";  # Find all TODOs in config

        # === Navigation ===
        home = "cd ~";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # === Fun/Useful ===
        weather = "curl wttr.in";                # Check the weather
      } // cfg.extraAliases;  # Merge user's custom aliases
    };

    # ========================================================================
    # Starship Prompt (Beautiful Shell Prompt)
    # ========================================================================

    programs.starship = {
      enable = true;

      settings = {
        # Configure the prompt format (what information to show)
        format = "$username$hostname$directory$git_branch$git_status$character";

        # Show username@hostname
        username = {
          format = "[$user]($style)@";
          show_always = true;
          style_user = "bold blue";
        };

        hostname = {
          format = "[$hostname]($style) ";
          ssh_only = false;
          style = "bold green";
        };

        # Current directory
        directory = {
          format = "[$path]($style) ";
          style = "bold cyan";
          truncation_length = 3;       # Show last 3 directories
          truncate_to_repo = true;     # Don't truncate in git repos
        };

        # Git branch name
        git_branch = {
          format = "on [$symbol$branch]($style) ";
          symbol = " ";              # Git icon
          style = "bold purple";
        };

        # Git status (shows if you have uncommitted changes)
        git_status = {
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
          style = "bold red";
        };

        # Prompt character (changes color based on last command success)
        character = {
          success_symbol = "[➜](bold green)";   # Green arrow if last command succeeded
          error_symbol = "[➜](bold red)";       # Red arrow if last command failed
        };
      };
    };

    # ========================================================================
    # FZF - Fuzzy Finder
    # ========================================================================

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;

      # Default command uses fd for faster searches
      defaultCommand = "fd --type f --hidden --follow --exclude .git";

      # Keybindings:
      # - Ctrl+T: Search files in current directory
      # - Ctrl+R: Search command history
      # - Alt+C: Change directory
      defaultOptions = [
        "--height 40%"
        "--border"
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };

    # ========================================================================
    # Zoxide - Smarter cd Command
    # ========================================================================

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;

      # Usage:
      # - z <partial-name>  Jump to a directory you've visited before
      # - zi                Interactive directory picker
      #
      # Examples:
      # - z doc      → cd ~/Documents
      # - z proj     → cd ~/projects/my-project
    };

    # ========================================================================
    # Zellij - Modern Terminal Multiplexer
    # ========================================================================
    #
    # Zellij is like tmux but more user-friendly and modern.
    # It lets you split your terminal into panes and create tabs.
    #
    # Quick Start:
    # - Run: zellij
    # - Press: Alt+n (new pane), Alt+h/j/k/l (navigate), Alt+t (new tab)
    # - Help: Ctrl+g (shows all keybindings)
    #
    # Learn more: https://zellij.dev/documentation/

    programs.zellij = {
      enable = true;
      enableBashIntegration = true;

      settings = {
        # UI Configuration
        theme = "default";
        pane_frames = true;
        simplified_ui = false;

        # Default layout (how the terminal is split)
        default_layout = "default";

        # Copy to clipboard
        copy_on_select = true;
        copy_clipboard = "system";

        # Mouse support
        mouse_mode = true;

        # Automatically attach to session if one exists
        on_force_close = "quit";

        # UI tweaks
        ui = {
          pane_frames = {
            rounded_corners = true;
          };
        };
      };
    };

    # ========================================================================
    # Bat - Better cat with Syntax Highlighting
    # ========================================================================

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";        # Nice dark theme
        pager = "less -FR";       # How to display long files
      };
    };
  };
}
