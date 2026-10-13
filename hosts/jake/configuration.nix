# hosts/jake/configuration.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  networking.hostName = "jake";

  # Disable systemd-boot (for duobooting)
  boot.loader.systemd-boot.enable = false;

  # Enable GRUB with EFI support and OS probing
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev"; # "nodev" is required for UEFI installs
    useOSProber = true;
    efiInstallAsRemovable = true; # Overwrites /EFI/BOOT/BOOTX64.EFI with GRUB
  };
  boot.loader.efi.canTouchEfiVariables = false;

  # Prevent Bluetooth controller dropping
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # Graphics (Nvidia Desktop)
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

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
