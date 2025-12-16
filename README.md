# Work Development Environment

Declarative NixOS/Home Manager configuration for C# development and database work on WSL.

## Features

- **.NET Development**: .NET 8/9 SDKs, Rider IDE, OmniSharp, build tools
- **Database Tools**: PostgreSQL, SQL Server, SQLite clients, DataGrip IDE
- **GUI Applications**: Full WSLg support for running Linux GUI apps on Windows
- **Terminal Environment**: Modern CLI tools, Git configuration, shell aliases
- **Composable Modules**: Enable only what you need

## Quick Start

### Option 1: Use the Template (Recommended)

**The fastest way to get started!** This repository includes a complete starter template with everything pre-configured.

The template provides:
- Complete flake setup with all inputs configured
- Pre-configured work development environment
- Example custom modules to learn modular configuration
- Modern shell environment with Starship, Zellij, FZF, and more
- Detailed step-by-step documentation

**To use the template:**

1. Install [NixOS-WSL](https://github.com/nix-community/NixOS-WSL)

2. Copy the template files to `/etc/nixos/`:
   ```bash
   sudo cp -r template/* /etc/nixos/
   ```

3. Customize the TODOs (username, git config, etc.):
   ```bash
   cd /etc/nixos
   grep -rn "TODO" . --color=always
   ```

4. Rebuild:
   ```bash
   cd /etc/nixos
   sudo nixos-rebuild switch --flake .#nixos-wsl
   ```

**See [template/README.md](template/README.md) for complete instructions and details!**

---

### Option 2: Manual Standalone Setup

If you prefer to set up everything manually or want a minimal configuration:

1. Install NixOS-WSL following [official instructions](https://github.com/nix-community/NixOS-WSL)

2. Create a basic configuration:

```nix
# /etc/nixos/configuration.nix
{ inputs, ... }:
{
  imports = [
    inputs.work-dev.nixosModules.default
  ];

  # Enable the developer profile (includes everything)
  work-dev.profiles.developer = true;

  # Or enable modules individually:
  # work-dev.dotnet.enable = true;
  # work-dev.databases.enable = true;
  # work-dev.gui-apps.enable = true;
  # work-dev.terminal.enable = true;
  # work-dev.wslg.enable = true;

  # Optional: Configure git for work
  work-dev.terminal.gitConfig = {
    userName = "Your Name";
    userEmail = "you@work.com";
  };
}
```

3. Add this flake to your inputs in `/etc/nixos/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    work-dev.url = "github:YOUR-ORG/work-nix-config";
  };

  outputs = { nixpkgs, work-dev, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        work-dev.nixosModules.default
      ];
    };
  };
}
```

4. Rebuild: `sudo nixos-rebuild switch --flake .#your-hostname`

---

### Option 3: Add to Existing Nix Config

If you already have a personal NixOS configuration:

1. Add this flake as an input:

```nix
# In your flake.nix inputs
work-dev.url = "github:YOUR-ORG/work-nix-config";
```

2. Import in your WSL host configuration:

```nix
# hosts/your-wsl-host/default.nix
{ inputs, ... }:
{
  imports = [
    inputs.work-dev.nixosModules.default
  ];

  work-dev.profiles.developer = true;
}
```

3. Update and rebuild:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#your-hostname
```

## Module Reference

### `work-dev.dotnet`

C# and .NET development tools.

**Options:**
- `enable` - Enable .NET development tools
- `sdkVersions` - List of .NET SDK packages (default: SDK 8 & 9)
- `enableOmnisharp` - Enable OmniSharp LSP (default: true)
- `globalTools` - Global .NET tools to install

**Shell aliases:** `dn`, `dnr`, `dnb`, `dnt`, `dnw`, `dnef`

### `work-dev.databases`

Database client tools and utilities.

**Options:**
- `enable` - Enable database tools
- `postgresql.enable` - PostgreSQL client (default: true)
- `sqlserver.enable` - SQL Server tools (default: true)
- `mysql.enable` - MySQL/MariaDB client (default: false)
- `sqlite.enable` - SQLite tools (default: true)

**Shell aliases:** `pg`, `sqlcmd`, `sq`

### `work-dev.gui-apps`

GUI applications via WSLg.

**Options:**
- `enable` - Enable GUI applications
- `jetbrains.rider` - Install Rider IDE (default: true)
- `jetbrains.datagrip` - Install DataGrip (default: true)
- `browsers.enable` - Install browsers (default: true)
- `vscode` - Install VS Code (default: false)
- `teams` - Install Microsoft Teams (teams-for-linux) (default: false)

**Shell aliases:** `rider`, `datagrip`, `code`, `teams`

### `work-dev.wslg`

WSLg (Windows Subsystem for Linux GUI) support.

**Options:**
- `enable` - Enable WSLg support
- `fonts` - Font packages for GUI apps

Automatically configures display, fonts, D-Bus, and XDG portals.

### `work-dev.terminal`

Terminal tools and environment.

**Options:**
- `enable` - Enable terminal tools
- `gitConfig.enable` - Configure Git (default: true)
- `gitConfig.userName` - Git user name
- `gitConfig.userEmail` - Git email
- `tools.enable` - Install dev tools (default: true)

**Shell aliases:** `gs`, `ga`, `gc`, `gp`, `gl`, `gd`, `ls`, `ll`, etc.

## Profiles

Pre-configured combinations of modules:

- **`minimal`** - Terminal tools only (no GUI)
- **developer** - Full setup (all modules enabled)
- **database-admin** - Database tools + DataGrip

Use profiles for quick setup:

```nix
work-dev.profiles.developer = true;
```

Or enable modules individually for fine control.

## WSLg Notes

WSLg is built into WSL2 and requires:
- Windows 11 or Windows 10 22H2+
- WSL 2 (not WSL 1)
- Up-to-date WSL kernel

GUI apps will appear as native Windows windows. No manual X server setup needed!

**Testing WSLg:**
```bash
xeyes  # Should show a GUI window
```

## Updating

To pull the latest changes:

```bash
nix flake update work-dev
sudo nixos-rebuild switch --flake .#your-hostname
```

## Contributing

This configuration is shared across the team. To contribute:

1. Fork or clone this repository
2. Make your changes
3. Test locally: `nix flake check`
4. Submit a pull request

## License

MIT (or your organization's preference)
