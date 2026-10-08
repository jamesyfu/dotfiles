# common.nix
{ config, lib, pkgs, ... }:

{
  # Core Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Flatpak
  services.flatpak.enable = true;

  # Networking & Locale
  networking.networkmanager.enable = true;
  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
    ];
  };

  # Graphical Desktop: KDE Plasma 6 on Wayland
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Printing & Network Discovery (Canon Pixma)
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # PipeWire & WirePlumber (No suspend idle)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.extraConfig."99-disable-suspend" = {
    "monitor.alsa.rules" = [{
      matches = [{ "node.name" = "~alsa_input.*"; } { "node.name" = "~alsa_output.*"; }];
      actions.update-props."session.suspend-timeout-seconds" = 0;
    }];
    "monitor.bluez.rules" = [{
      matches = [{ "node.name" = "~bluez_input.*"; } { "node.name" = "~bluez_output.*"; }];
      actions.update-props."session.suspend-timeout-seconds" = 0;
    }];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Enable = "Source,Sink,Media,Socket";
      Experimental = true;
    };
  };

  # Users
  users.users.james = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # SSH & KWallet
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };
  environment.variables.SSH_ASKPASS_REQUIRE = "prefer";

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
  };

  # System Plumbing & Base Utilities
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    wget
    tree

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

    # Video Playback
    vlc
    mpv
    haruna

    # Python
    uv
  ];

  # for mason to work in neovim
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
    curl

    # for Scientific Python wheels (NumPy, SciPy, Matplotlib, Jupyter)
    glib
    libGL
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libICE
    xorg.libSM
  ];

  programs.firefox.enable = true;
  programs.bash.blesh.enable = true;

  # Btrfs auto-scrub
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };
}
