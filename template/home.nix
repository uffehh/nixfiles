{ config, pkgs, ... }:

{
  # ============================================================================
  # Home Manager Configuration
  # ============================================================================

  # Import custom modules (demonstrates modular configuration)
  # This automatically imports shell.nix and git.nix from ./modules/home-manager/
  imports = [
    ./modules/home-manager
  ];

  # ============================================================================
  # Basic Home Manager Settings
  # ============================================================================

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "yourname";  # TODO: Change this to match your username in configuration.nix
  home.homeDirectory = "/home/yourname";  # TODO: Change this too

  # This value determines the Home Manager release which the configuration is
  # compatible with. Don't change this unless you know what you're doing!
  home.stateVersion = "24.05";

  # ============================================================================
  # Custom Module Configuration (Examples of Modular Setup)
  # ============================================================================

  # Enable and configure shell module (see modules/home-manager/shell.nix)
  mytemplate.shell = {
    enable = true;
    funPackages = true;  # Install neofetch, fortune, cowsay, lolcat

    # Add your own custom aliases here!
    extraAliases = {
      # Example: Uncomment and customize these
      # myproject = "cd ~/projects/my-project";
      # deploy = "./deploy.sh";
    };
  };

  # Enable and configure git module (see modules/home-manager/git.nix)
  mytemplate.git = {
    enable = true;

    # TODO: Change these to your actual information
    userName = "Your Name";
    userEmail = "you@example.com";

    # Add your own custom git aliases here!
    extraAliases = {
      # Example: Uncomment and customize these
      # pushf = "push --force-with-lease";
      # amend = "commit --amend --no-edit";
    };

    # Add your own global git ignore patterns here!
    extraIgnores = [
      # Example:
      # "*.local"
      # ".env.local"
    ];
  };

  # ============================================================================
  # User Packages
  # ============================================================================

  # Packages installed for this user only
  # (System-wide packages are in configuration.nix)
  # (Shell tools are in modules/home-manager/shell.nix)
  home.packages = with pkgs; [
    # === Additional Development Tools ===
    # Add any personal tools you want here!
    # Examples:
    # nodejs
    # python3
    # rustc
    # go

    # === Productivity Tools ===
    # Examples:
    # obsidian
    # slack
  ];

  # ============================================================================
  # Environment Variables
  # ============================================================================

  home.sessionVariables = {
    # Add any personal environment variables here
    # Examples:
    # PROJECTS_DIR = "$HOME/projects";
    # EDITOR = "nvim";  # (already set in shell module)
  };

  # ============================================================================
  # Additional Program Configurations
  # ============================================================================

  # Most common tools are configured in the modules, but you can add more here.
  # For example, if you want to configure a specific editor or tool:

  # programs.neovim = {
  #   enable = true;
  #   # ... your neovim config
  # };

  # ============================================================================
  # Let Home Manager manage itself
  # ============================================================================

  programs.home-manager.enable = true;
}
