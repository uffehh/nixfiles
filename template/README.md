# NixOS WSL Starter Template

Welcome! This template provides a complete, ready-to-use NixOS configuration for WSL with all the work development tools pre-configured.

## What's Included

- **NixOS Flake Setup** - Modern, declarative system configuration
- **Home Manager** - User-level package and dotfile management
- **Example Modules** - Learn modular configuration with 3 fully-commented example modules
- **Work Development Tools** - Automatic inclusion of the shared work-nix-config (C#, databases, etc.)
- **Modern Shell Environment** - Starship prompt, Zellij multiplexer, FZF, Zoxide
- **Developer CLI Tools** - bat, ripgrep, fd, delta, and more
- **nh** - The best tool for rebuilding your system (`nh os switch --ask`)

## Prerequisites

1. **Windows 11** (or Windows 10 22H2+) with WSL 2
2. **NixOS-WSL installed** - Follow the [NixOS-WSL installation guide](https://github.com/nix-community/NixOS-WSL#quick-start)

## Installation Steps

### 1. Copy Template Files

Copy all files from this `template/` directory to `/etc/nixos/`:

```bash
# Backup existing configuration (just in case)
sudo cp -r /etc/nixos /etc/nixos.backup

# Copy template files
sudo cp -r template/* /etc/nixos/
```

### 2. Find and Fill Out All TODOs

**IMPORTANT:** The template contains several `TODO` comments that you MUST customize before building.

To find all TODOs, run this command:

```bash
cd /etc/nixos
grep -rn "TODO" . --color=always
```

This will show you all the places you need to customize. Here's what you need to change:

#### **In `configuration.nix`:**
- `wsl.defaultUser` - Change "yourname" to your actual username
- `networking.hostName` - Choose a hostname for your system
- `users.users.yourname` - Change "yourname" to match the username above
- `work-dev.terminal.gitConfig` - Add your real name and work email

#### **In `home.nix`:**
- `home.username` - Must match the username in configuration.nix
- `home.homeDirectory` - Update to match your username
- `mytemplate.git.userName` - Your full name for git commits
- `mytemplate.git.userEmail` - Your email for git commits

#### **In `flake.nix`:**
- `home-manager.users.yourname` - Must match your username

**Pro tip:** Search and replace "yourname" with your actual username to fix most of these at once!

```bash
# Example: Replace all instances of "yourname" with "alice"
cd /etc/nixos
find . -name "*.nix" -exec sed -i 's/yourname/alice/g' {} +
```

**After your first rebuild**, you can use the handy `find-todos` alias to check for any remaining TODOs:

```bash
find-todos  # Shows all remaining TODOs in your config
```

### 3. Rebuild Your System

Now comes the magic! For your **first rebuild**, you need to use the traditional command:

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos-wsl
```

**Note:** The first rebuild will take a while (10-30 minutes) as it downloads and builds everything. Grab some coffee!

After this first rebuild, `nh` will be installed and you can use the much nicer command for all future rebuilds:

```bash
nh os switch --ask
```

The `--ask` flag will prompt you before making changes and show you exactly what's changing. Much better than the traditional command!

### 4. Verify Everything Works

After rebuilding, you should have:

```bash
# Check .NET is installed
dotnet --version

# Check modern CLI tools
eza --version
bat --version
zellij --version

# Try out the new tools!
neofetch              # Show system info
z ~                   # Jump home with zoxide
# Press Ctrl+R in bash to search command history with fzf

# Helpful aliases are available:
rebuild               # Same as: nh os switch --ask
find-todos            # Find any remaining TODOs in your config
edit-config           # Quick edit configuration.nix

# Check GUI apps work (if you enabled them)
rider &
```

## Using nh - Your New Best Friend

`nh` is a helper tool that makes NixOS rebuilds easier and safer:

```bash
# Rebuild system configuration (use this most of the time)
nh os switch --ask

# Just build without activating (test your changes)
nh os build

# Show what would change without building
nh os test
```

**Pro tip:** The `--ask` flag shows you exactly what will change and asks for confirmation. Perfect for learning!

## Understanding the Module Structure

This template includes example modules to teach you modular NixOS configuration. Modules help you organize your config into reusable, maintainable pieces.

### What Are Modules?

Think of modules as plugins for your NixOS configuration. Instead of having one giant file with everything, you split related configurations into separate files.

### Template Modules

This template includes three example modules:

#### 1. **`modules/home-manager/shell.nix`**
**What it does:** Configures your shell environment with modern tools

**Includes:**
- Starship (beautiful prompt)
- Zellij (modern terminal multiplexer)
- FZF (fuzzy finder - try Ctrl+R for history!)
- Zoxide (smart cd command - use `z` instead of `cd`)
- Bat (better cat with syntax highlighting)
- Fun packages (neofetch, fortune, cowsay)

**How to customize:**
```nix
# In home.nix
mytemplate.shell = {
  enable = true;
  funPackages = false;  # Disable fun packages if you want
  extraAliases = {
    myproject = "cd ~/my-project";
  };
};
```

#### 2. **`modules/home-manager/git.nix`**
**What it does:** Configures Git with your information and useful aliases

**Includes:**
- Git aliases (st, co, br, lg, undo, etc.)
- Delta for beautiful diffs
- Global gitignore patterns

**How to customize:**
```nix
# In home.nix
mytemplate.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "you@example.com";
  extraAliases = {
    pushf = "push --force-with-lease";
  };
};
```

#### 3. **`modules/nixos/wsl-extras.nix`**
**What it does:** Adds WSL-specific utilities and tweaks

**Includes:**
- wslu utilities (wslview, wslpath)
- Disables suspend/hibernate (not needed in WSL)
- Adds helpful message of the day

**How to customize:**
```nix
# In configuration.nix
mytemplate.wsl-extras = {
  enable = true;
  disableSleep = true;
  installUtils = true;
};
```

### Why Use Modules?

1. **Organization:** Related settings stay together
2. **Reusability:** Copy modules between configs
3. **Learning:** Each module is heavily commented
4. **Maintainability:** Easier to update and debug

### Creating Your Own Modules

Want to create your own module? Here's a simple example:

```nix
# modules/home-manager/my-module.nix
{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mytemplate.my-module;
in
{
  options.mytemplate.my-module = {
    enable = mkEnableOption "my custom module";
  };

  config = mkIf cfg.enable {
    # Your configuration here
    home.packages = [ pkgs.some-package ];
  };
}
```

Then add it to `modules/home-manager/default.nix`:
```nix
{
  imports = [
    ./shell.nix
    ./git.nix
    ./my-module.nix  # Add your new module
  ];
}
```

And enable it in `home.nix`:
```nix
mytemplate.my-module.enable = true;
```

## Customizing Your Setup

### Enable/Disable Work Modules

In `/etc/nixos/configuration.nix`, you can toggle specific work tools:

```nix
# Enable/disable individual modules
work-dev.dotnet.enable = true;       # C# and .NET tools
work-dev.databases.enable = true;    # Database clients
work-dev.gui-apps.enable = true;     # Rider, DataGrip, etc.
work-dev.wslg.enable = true;         # WSLg GUI support
```

Or use a profile for everything:

```nix
work-dev.profiles.developer = true;  # Enables all modules
```

### Add Your Own Packages

System-wide packages go in `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  nh
  git
  vim
  # Add your packages here
  htop
  curl
];
```

User packages go in `home.nix`:

```nix
home.packages = with pkgs; [
  # Add your personal tools here
  neofetch
  fortune
];
```

### Change Your Shell

The template uses bash by default. To use zsh:

```nix
# In home.nix
programs.zsh.enable = true;
programs.bash.enable = false;  # Optional: disable bash
```

## Troubleshooting

### "error: getting status of '/etc/nixos/hardware-configuration.nix': No such file or directory"

This is normal for NixOS-WSL. The template doesn't include this file because WSL handles hardware automatically.

### Rebuild is taking forever

The first rebuild downloads a lot. Grab some coffee! Future rebuilds will be much faster.

### GUI apps don't start

Make sure you're on Windows 11 (or Windows 10 22H2+) and WSL 2:

```bash
wsl.exe --version
```

Update WSL if needed:

```powershell
# In Windows PowerShell
wsl --update
```

### Git integration not working

Double-check your git config in `configuration.nix` and rebuild:

```bash
git config --global --list
```

## Updating the System

### Update System Packages

```bash
# Update all flake inputs (nixpkgs, work-nix-config, etc.)
cd /etc/nixos
nix flake update

# Rebuild with new versions
nh os switch --ask
```

### Update Just work-nix-config

```bash
# Update only the work configuration
cd /etc/nixos
nix flake lock --update-input work-nix-config

# Rebuild
nh os switch --ask
```

## Learning More

- [NixOS Manual](https://nixos.org/manual/nixos/stable/) - Official documentation
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - User configuration guide
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix concepts
- [NixOS Discourse](https://discourse.nixos.org/) - Community help

## Getting Help

If you're stuck:

1. Check this README again
2. Ask your colleagues who use this setup
3. Search [NixOS Discourse](https://discourse.nixos.org/)
4. Check the [NixOS-WSL issues](https://github.com/nix-community/NixOS-WSL/issues)

Happy hacking!
