# hosts/cosette/configuration.nix

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../common.nix
    ];

  networking.hostName = "cosette"; # Define your hostname.

  # Secure Boot Configuration (Lanzaboote Engine)
  # Force the standard systemd-boot implementation off so Lanzaboote can take over
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Disable USB Power Management to prevent bluetooth controller dropping
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # Enable graphics driver support
  hardware.graphics.enable = true;

  # Load proprietary Nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for Wayland to work smoothly on Nvidia
    modesetting.enable = true;

    # Nvidia power management. Experimental, but can prevent wake-from-sleep bugs.
    powerManagement.enable = false;

    # Unfortunately we have to use the proprietary driver
    open = false;

    # Enable the Nvidia settings menu utility
    nvidiaSettings = true;

    # Choose the driver package
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # Host-specific utility: Secure Boot key management
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}


