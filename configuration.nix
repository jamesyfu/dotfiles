# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable Flatpak
  services.flatpak.enable = true;

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

  networking.hostName = "cosette"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons # Provides the standard Intelligent Pinyin engine
    ];
  };
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the Graphical Desktop Environment (xserver is a legacy term)
  services.xserver.enable = true;

  # Enable KDE Plasma 6 Desktop Environment with native Wayland
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Disable Audio Node Suspend on Idle (Fixes silent resume lag / audio cutoffs)
  services.pipewire.wireplumber.extraConfig."99-disable-suspend" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "~alsa_input.*"; }
          { "node.name" = "~alsa_output.*"; }
        ];
        actions = {
          update-props = {
            "session.suspend-timeout-seconds" = 0; # 0 disables suspend entirely
          };
        };
      }
    ];
    "monitor.bluez.rules" = [
      {
        matches = [
          { "node.name" = "~bluez_input.*"; }
          { "node.name" = "~bluez_output.*"; }
        ];
        actions = {
          update-props = {
            "session.suspend-timeout-seconds" = 0; # 0 disables suspend entirely
          };
        };
      }
    ];
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # wheel grants sudo power
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # SSH Agent with KDE Wallet Integration
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true; # Automatically hooks into the active DE's askpass
  };

  # Force OpenSSH to prefer the graphical prompt even inside a terminal
  environment.variables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Automate routine Btrfs background maintainence
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  # Allow unfree packages (because Nvidia)
  nixpkgs.config.allowUnfree = true;

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

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Enable high-quality audio routing and automatic controller discovery
        Enable = "Source,Sink,Media,Socket";
        Experimental = true; # Displays battery levels of connected headphones in KDE
      };
    };
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
  };

  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    wget
    tree
    ghostty
    fastfetch

    # Core extraction utilities for Mason
    unzip
    gnutar
    gzip

    # Neovim fuzzy-finding essentials
    ripgrep
    fd

    # Global Tree-sitter compilation tooling
    tree-sitter
    gcc

    # Secure Boot Key Management
    sbctl
  ];

  # for mason to work in neovim
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    curl
  ];

  programs.firefox.enable = true;
  programs.bash.blesh.enable = true;

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


