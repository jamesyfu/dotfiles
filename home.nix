{ config, pkgs, inputs, ... }:

{
  imports = [
    # This is what teaches Home Manager what 'services.flatpak' means!
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  home.username = "james";
  home.homeDirectory = "/home/james";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # packages
  home.packages = with pkgs; [
    godot_4
    kdePackages.okular
  ];

  # flatpaks
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    update.onActivation = true;
    packages = [
      "dev.vencord.Vesktop"
      "org.signal.Signal"
      "md.obsidian.Obsidian"
      "com.spotify.Client"
      "com.slack.Slack"
    ];
  };

  # symlinks
  xdg.configFile."ghostty".source = 
    config.lib.file.mkOutOfStoreSymlink /home/james/dotfiles/ghostty/.config/ghostty;
  home.file.".bashrc".source = 
    config.lib.file.mkOutOfStoreSymlink /home/james/dotfiles/bash/.bashrc;
  home.file.".bashrc.d".source = 
    config.lib.file.mkOutOfStoreSymlink /home/james/dotfiles/bash/.bashrc.d;
  home.file.".blerc".source = 
    config.lib.file.mkOutOfStoreSymlink /home/james/dotfiles/bash/.blerc;
}
