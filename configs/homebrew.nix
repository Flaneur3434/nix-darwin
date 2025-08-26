{ config, pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall"; # Remove things not declared
      extraFlags = [
        "--verbose"
      ];
    };

    # Add any custom taps here if needed
    taps = [
      "d12frosted/emacs-plus"
    ];

    # Formulae (command-line tools)
    brews = [
      "defaultbrowser"
      {
        name = "emacs-plus";
        args = [ "with-skamacs-icon" ];
        restart_service = true;
      }
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
      "utm"
    ];
  };
}
