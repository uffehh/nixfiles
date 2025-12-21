{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # If you have a hardware-configuration.nix, import it here
    # NixOS-WSL typically doesn't need this, but it's good to keep the import
    # ./hardware-configuration.nix

    # Import custom modules (demonstrates modular configuration)
    ./modules/nixos
  ];

  # ============================================================================
  # WSL Configuration
  # ============================================================================

  wsl = {
    enable = true;
    defaultUser = "yourname"; # TODO: Change this to your username

    # Start systemd on boot (required for Docker, services, etc.)
    wslConf.automount.root = "/mnt";

    # Optional: Automatically start your user session
    startMenuLaunchers = true;
  };

  # ============================================================================
  # System Settings
  # ============================================================================

  # TODO: Change this to your preferred hostname
  networking.hostName = "nixos-wsl";

  # Set your time zone
  time.timeZone = "Europe/Copenhagen";

  # Internationalization settings
  i18n.defaultLocale = "en_US.UTF-8";

  # ============================================================================
  # User Configuration
  # ============================================================================

  # TODO: Change "yourname" to your actual username
  users.users.yourname = {
    isNormalUser = true;
    home = "/home/yourname"; # TODO: Update this too
    description = "Your Name"; # TODO: Add your actual name

    # Groups give you permissions (wheel = sudo, docker = Docker access, etc.)
    extraGroups = [
      "wheel" # Allows sudo
      "networkmanager"
      "docker" # If you plan to use Docker
    ];

    # Your user will use bash by default
    # You can change this to zsh in home.nix
    shell = pkgs.bash;
  };

  # Allow your user to use sudo without a password (optional, but convenient for WSL)
  security.sudo.wheelNeedsPassword = true;

  # ============================================================================
  # Work Development Environment
  # ============================================================================

  # OPTION 1: Enable everything at once with the developer profile
  work-dev.profiles.developer = true;
  work-dev.gui-apps.jetbrains.rider = false;    # Disable Rider IDE
  work-dev.gui-apps.jetbrains.datagrip = false; # Disable DataGrip IDE
  work-dev.gui-apps.teams = false;              # Disable Microsoft Teams

  # OPTION 2: Or comment out the line above and enable modules individually:
  # work-dev.dotnet.enable = true;       # C# and .NET development tools
  # work-dev.databases.enable = true;    # PostgreSQL, SQL Server clients
  # work-dev.gui-apps.enable = true;     # Rider, DataGrip IDEs
  # work-dev.wslg.enable = true;         # WSLg GUI support
  # work-dev.terminal.enable = true;     # Enhanced terminal tools

  # Configure Git for work
  # TODO: Replace with your actual name and email
  work-dev.terminal.gitConfig = {
    userName = "Your Name";
    userEmail = "you@work.com";
  };

  # ============================================================================
  # Custom Template Modules (Examples of Modular Configuration)
  # ============================================================================

  # Enable WSL-specific extras (see modules/nixos/wsl-extras.nix)
  mytemplate.wsl-extras = {
    enable = true;
    disableSleep = true;    # Disable suspend/hibernate in WSL
    installUtils = true;    # Install wslu (wslview, wslpath, etc.)
  };

  # ============================================================================
  # System Packages
  # ============================================================================

  # Packages installed system-wide (available to all users)
  environment.systemPackages = with pkgs; [
    # === Essential Tools ===
    nh # This lets you run "nh os switch --ask"
    git # Version control
    vim # Text editor
    wget # Download files
    curl # HTTP requests

    # === System Tools ===
    htop # Process viewer
    killall # Kill processes by name
    file # Identify file types
    unzip # Extract zip files
    zip # Create zip files

    # === Network Tools ===
    dig # DNS lookup
    nmap # Network scanning

    # You can add more packages here as needed!
  ];

  # ============================================================================
  # Nix Configuration
  # ============================================================================

  # Enable flakes and the new nix command (required for this setup)
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];

    # Automatically optimize the Nix store (saves disk space)
    auto-optimise-store = true;
  };

  # Automatically clean up old generations (saves disk space)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ============================================================================
  # Programs
  # ============================================================================

  # Enable some useful programs system-wide
  programs.bash.completion.enable = true; # Tab completion for bash
  programs.git.enable = true; # Git (already in systemPackages, but good to enable)

  # Optional: Enable Docker (uncomment if you need it)
  # virtualisation.docker = {
  #   enable = true;
  #   enableOnBoot = true;
  # };

  # ============================================================================
  # System State Version
  # ============================================================================

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this unless you know what you're doing!
  system.stateVersion = "25.05"; # Did you read the comment?
}
