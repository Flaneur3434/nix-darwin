{ config, pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      # If you remove a cask from your config, you'll need to manually uninstall
      # it with: brew uninstall --cask <name>
      cleanup = "none"; # Don't remove anything automatically
      autoUpdate = false; # Don't auto-update during activation
      upgrade = false; # Don't auto-upgrade during activation
      extraFlags = [
        "--verbose"
      ];
    };

    # Add any custom taps here if needed
    taps = [
      "d12frosted/emacs-plus"
      "grishka/grishka"
    ];

    # Formulae (command-line tools)
    brews = [
      "defaultbrowser"
      "tmux"
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
      "tailscale-app"
      "discord"
      "rustdesk"
      "qbittorrent"
      "zoom"
      "iterm2"
      "visual-studio-code"
      "flameshot"
      "balenaetcher"
      "moonlight"
      "monitorcontrol"
      {
        name = "neardrop";
        args = { no_quarantine = true; };
      }
    ];
  };
}
