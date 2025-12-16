# ============================================================================
# Home Manager Modules Index
# ============================================================================
#
# This file imports all Home Manager modules in this directory.
# When you import ./modules/home-manager in your home.nix, this file
# automatically imports all the individual module files.
#
# This is a common pattern in NixOS/Home Manager to keep things organized.
#
# ============================================================================

{
  imports = [
    ./shell.nix
    ./git.nix
  ];
}
