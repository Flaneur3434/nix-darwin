{
  config,
  pkgs,
  lib,
  ...
}:

let

  # Common extensions for both profiles
  commonExtensions = with pkgs.nur.repos.rycee.firefox-addons; [
    multi-account-containers
    temporary-containers
    videospeed
    container-tabs-sidebar
    hover-zoom-plus
  ];

  commonSettings = {
    # Open previous tabs and windows
    "browser.startup.page" = 3; # 3 = Resume previous session

    # Always use cursor keys to navigate (caret browsing)
    "accessibility.browsewithcaret" = true;

    # Disable Picture in Picture
    "media.videocontrols.picture-in-picture.enabled" = false;
    "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;

    # Don't delete cookies
    "network.cookie.lifetimePolicy" = 0; # 0 = Keep cookies normally
    "privacy.sanitize.sanitizeOnShutdown" = false;
    "privacy.clearOnShutdown.cookies" = false;

    # Don't clear history
    "privacy.clearOnShutdown.history" = false;
    "places.history.enabled" = true;

    # DNS over HTTPS - Mullvad
    "network.trr.mode" = 2; # 2 = Use DoH with fallback to system DNS
    "network.trr.uri" = "https://dns.mullvad.net/dns-query";
    "network.trr.custom_uri" = "https://dns.mullvad.net/dns-query";

    # Enable Tab Groups
    "browser.tabs.groups.enabled" = true;
  };
in
{
  programs.librewolf = {
    enable = true;
    profiles = {
      personal = {
        id = 0;
        name = "Personal";
        isDefault = true;
        settings = commonSettings // {
          # Personal-specific settings can be added here
        };

        extensions.packages =
          commonExtensions
          ++ (with pkgs.nur.repos.rycee.firefox-addons; [
            violentmonkey
          ])
          ++ [
            # Nix can't access attributes that start with numbers directly. You
            # have to reference them outside the with block or use lib.getAttr.
            pkgs.nur.repos.rycee.firefox-addons."10ten-ja-reader"
          ];
      };

      university = {
        id = 1;
        name = "University";
        settings = commonSettings // {
          # Fullscreen only fills window, not actual fullscreen
          "full-screen-api.ignore-widgets" = true;
          "full-screen-api.macos-native-full-screen" = false;
        };
        extensions.packages = commonExtensions;
      };
    };
  };

  # Force overwrite the profiles.ini file
  home.file."Library/Application Support/LibreWolf/profiles.ini".force = true;

  # Set default browser using built-in open command
  # DAG (Directed Acyclic Graph): Controls execution order during Home Manager activation
  # entryAfter ["writeBoundary"] = run this script AFTER the writeBoundary phase
  # writeBoundary phase = when files are written and packages (like LibreWolf) are installed
  home.activation.setLibreWolfDefault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x "/opt/homebrew/bin/defaultbrowser" ]; then
      echo "Setting LibreWolf as default browser"
      /opt/homebrew/bin/defaultbrowser librewolf
      echo "LibreWolf set as default browser"
    else
      echo "defaultbrowser tool not found at /opt/homebrew/bin/defaultbrowser"
    fi
  '';
}
