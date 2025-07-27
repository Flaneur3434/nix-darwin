{ config, pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall"; # Remove things not declared

    # Add any custom taps here if needed
    taps = [
      
    ];

    # Formulae (command-line tools)
    brews = [
      "defaultbrowser"
    ];

    # Casks (GUI applications)
    casks = [
      "keepassxc"
      "signal"
      "karabiner-elements"
      "tailscale"
      "discord"
      "rustdesk"
      "qbittorrent"
      "vlc"
      "zoom"
      "vmware-fusion"
    ];
  };
}
