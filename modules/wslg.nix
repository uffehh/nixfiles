{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.work-dev.wslg;
in
{
  options.work-dev.wslg = {
    enable = mkEnableOption "WSLg (Windows Subsystem for Linux GUI) support";

    fonts = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        dejavu_fonts
        liberation_ttf
      ];
      description = "Fonts to install for GUI applications";
    };
  };

  config = mkIf cfg.enable {
    # WSLg automatically sets DISPLAY and WAYLAND_DISPLAY
    # But we ensure they're available if not set
    environment.sessionVariables = {
      # WSLg uses :0 for X11 display
      DISPLAY = mkDefault ":0";
      # Enable Wayland for apps that support it
      WAYLAND_DISPLAY = mkDefault "wayland-0";
      # Qt applications
      QT_QPA_PLATFORM = mkDefault "wayland;xcb";
      # GTK applications prefer Wayland
      GDK_BACKEND = mkDefault "wayland,x11";
      # Enable fractional scaling for HiDPI displays
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      # Fix Java GUI applications
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    # Install fonts for GUI applications
    fonts.packages = cfg.fonts;

    # Enable D-Bus for GUI applications
    services.dbus.enable = true;

    # Essential packages for GUI support
    environment.systemPackages = with pkgs; [
      # X11 utilities
      xorg.xeyes  # Useful for testing X11 display
      xorg.xhost
      xdotool

      # Wayland utilities
      wl-clipboard

      # Common GUI libraries (many apps need these)
      gtk3
      qt5.qtbase

      # Desktop integration
      xdg-utils
      shared-mime-info
    ];

    # XDG Portal for better desktop integration
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common.default = "gtk";
    };
  };
}
