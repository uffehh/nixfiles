{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.work-dev.dotnet;

  # Combine all configured .NET SDKs using the official nixpkgs function
  # This properly handles multiple SDK versions for IDE discovery
  combinedDotnetSdk = pkgs.dotnetCorePackages.combinePackages cfg.sdkVersions;
in
{
  options.work-dev.dotnet = {
    enable = mkEnableOption "C# and .NET development tools";

    sdkVersions = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        dotnet-sdk_8  # .NET 8 LTS
        dotnet-sdk_9  # .NET 9 (latest)
      ];
      description = ".NET SDK versions to install";
    };

    enableOmnisharp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OmniSharp language server for editors";
    };

    globalTools = mkOption {
      type = types.listOf types.str;
      default = [
        "dotnet-ef"           # Entity Framework CLI
        "dotnet-format"       # Code formatter
        "dotnet-outdated-tool" # Check for outdated packages
      ];
      description = "Global .NET tools to install";
    };
  };

  config = mkIf cfg.enable {
    # Install .NET SDKs - using combined SDK for IDE discovery
    environment.systemPackages = [
      combinedDotnetSdk

      # Additional development tools
      (mkIf cfg.enableOmnisharp pkgs.omnisharp-roslyn)

      # Mono for legacy .NET Framework projects (if needed)
      pkgs.mono

      # MSBuild and related tools
      pkgs.msbuild

      # NuGet package manager
      pkgs.nuget

      # .NET runtime for running apps without SDK
      pkgs.dotnet-runtime_8
      pkgs.dotnet-aspnetcore_8
    ];

    # Set up environment for .NET
    environment.sessionVariables = {
      # Disable .NET telemetry
      DOTNET_CLI_TELEMETRY_OPTOUT = "1";

      # Enable .NET CLI colors
      DOTNET_CLI_UI_LANGUAGE = "en-US";

      # Set NuGet cache location (optional, defaults to ~/.nuget)
      # NUGET_PACKAGES = "$HOME/.nuget/packages";

      # Improve build performance
      DOTNET_SKIP_FIRST_TIME_EXPERIENCE = "1";

      # Use system's OpenSSL
      DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER = "0";

      # Set DOTNET_ROOT to combined SDK path for multi-version discovery (critical for IDEs like Rider)
      DOTNET_ROOT = "${combinedDotnetSdk}";
    };

    # Add shell aliases for common dotnet commands
    environment.shellAliases = {
      dn = "dotnet";
      dnr = "dotnet run";
      dnb = "dotnet build";
      dnt = "dotnet test";
      dnw = "dotnet watch";
      dnef = "dotnet ef";
    };

    # Add .NET tools directory to PATH
    # Global tools install to ~/.dotnet/tools by default
    programs.bash.interactiveShellInit = ''
      export PATH="$HOME/.dotnet/tools:$PATH"
    '';

    programs.zsh.interactiveShellInit = ''
      export PATH="$HOME/.dotnet/tools:$PATH"
    '';
  };
}
