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
    hover-zoom-plus
    tree-style-tab
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

    # Tab settings
    "browser.tabs.groups.enabled" = true;

    # Sidebar settings
    "sidebar.verticalTabs" = true;
    "sidebar.expandOnHover" = true;
    "browser.ml.chat.sidebar" = false;

    # Enable userChrome
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "layout.css.has-selector.enabled" = true;
  };

  userChromeCSS = ''
    /***** Hide horizontal tab bar only while TST is visible *****/
    /* Based on: https://github.com/piroor/treestyletab/wiki/Code-snippets-for-custom-style-rules#hide-horizontal-tabs-at-the-top-of-the-window-1349-1672-2147 */
    html#main-window body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #TabsToolbar {
      visibility: collapse !important;
    }

    /* Safety: avoid ghost hit-targets when tabs-in-titlebar is on (same condition) */
    html#main-window body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #TabsToolbar > .toolbar-items {
      opacity: 0 !important;
      pointer-events: none !important;
    }

    /* Remove the tiny vertical line from the titlebar when tabs-in-titlebar is enabled */
    #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar .titlebar-spacer {
      border-inline-end: none !important;
    }

    /***** Hide ONLY TST's sidebar header/title *****/
    #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
      display: none !important;
    }

    /* Optional: keep your tiny tab spacing tweak (if anything still renders tabs anywhere) */
    .tab {
      margin-inline: 1px !important;
    }
  '';
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

        userChrome = userChromeCSS;
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
        userChrome = userChromeCSS;
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
