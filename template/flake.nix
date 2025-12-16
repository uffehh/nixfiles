{
  description = "NixOS WSL configuration for work development";

  inputs = {
    # Main package repository (unstable = latest packages)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # NixOS-WSL for Windows Subsystem for Linux integration
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs version
    };

    # Home Manager for user-level configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs version
    };

    # Work development environment (shared team configuration)
    work-nix-config = {
      url = "github:jmh_DAC/nixfiles";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs version
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    home-manager,
    work-nix-config,
    ...
  }: {
    # This defines your system configuration
    # The name "nixos-wsl" is what you'll use with: nh os switch --ask
    nixosConfigurations.nixos-wsl = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # WSL uses 64-bit Linux

      modules = [
        # Import the NixOS-WSL module (required for WSL)
        nixos-wsl.nixosModules.wsl

        # Import your main system configuration
        ./configuration.nix

        # Import Home Manager as a NixOS module
        home-manager.nixosModules.home-manager
        {
          # Home Manager settings
          home-manager.useGlobalPkgs = true; # Use system nixpkgs
          home-manager.useUserPackages = true; # Install packages to /etc/profiles

          # TODO: Update "yourname" to match your username in configuration.nix
          home-manager.users.yourname = import ./home.nix;

          # Pass inputs to your configurations
          home-manager.extraSpecialArgs = {inherit work-nix-config;};
        }

        # Import the shared work development modules
        work-nix-config.nixosModules.default
      ];

      # Pass inputs to your configuration
      specialArgs = {inherit work-nix-config;};
    };
  };
}
