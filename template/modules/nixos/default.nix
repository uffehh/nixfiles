# ============================================================================
# NixOS Modules Index
# ============================================================================
#
# This file imports all NixOS system-level modules in this directory.
# When you import ./modules/nixos in your configuration.nix, this file
# automatically imports all the individual module files.
#
# This is a common pattern in NixOS to keep things organized.
#
# ============================================================================

{
  imports = [
    ./wsl-extras.nix
  ];
}
