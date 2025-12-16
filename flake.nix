{
  description = "Work development environment for C# and database work";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    # NixOS modules that can be imported by systems
    nixosModules = {
      default = import ./modules;
      wslg = import ./modules/wslg.nix;
    };

    # Home Manager modules
    homeManagerModules = {
      default = import ./modules;
      dotnet = import ./modules/dotnet.nix;
      databases = import ./modules/databases.nix;
      gui-apps = import ./modules/gui-apps.nix;
      terminal = import ./modules/terminal.nix;
      wslg = import ./modules/wslg.nix;
    };

    # Overlays if needed
    overlays.default = final: prev: {
      # Add any custom packages or overrides here
    };
  };
}
