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
    "accessibility.browsewithcaret" = false;

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
    "sidebar.verticalTabs" = false; # Using tree-style-tabs
    "sidebar.expandOnHover" = true;
    "browser.ml.chat.sidebar" = false;
    "sidebar.visibility" = "hide-sidebar";

    # Enable userChrome
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "layout.css.has-selector.enabled" = true;
  };

  userChromeCSS = ''
    /***** Tree Style Tab + macOS traffic lights layout *****/
    /* Behavior:
    * - When TST sidebar is OPEN:
    *     - Hide horizontal tab strip
    *     - Collapse titlebar height (no wasted top bar)
    *     - Move macOS traffic lights into the main toolbar (over a Flexible Space)
    *     - Hide TST’s own sidebar header
    * - When TST sidebar is CLOSED:
    *     - Firefox behaves normally (tabs + traffic lights in default place)
    *
    * NOTE: In Customize Toolbar, add a "Flexible Space" at the FAR LEFT of the
    * main toolbar; the traffic lights will sit on top of that.
    */

    /* This is the condition we reuse:
    *
    * html#main-window body:has(
    *   #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"]
    *                [checked="true"]:not([hidden="true"])
    * )
    */

    /***** 1. Hide horizontal tab contents only when TST is visible *****/
    html#main-window body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #TabsToolbar > .toolbar-items {
      visibility: collapse !important;
    }

    /***** 2. Collapse the titlebar only when TST is visible *****/
    html#main-window[tabsintitlebar="true"] body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #titlebar {
      appearance: none !important;
      height: 0 !important;
    }

    html#main-window[tabsintitlebar="true"] body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #titlebar > #toolbar-menubar {
      margin-top: 0 !important;
    }

    html#main-window[tabsintitlebar="true"] body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #TabsToolbar {
      min-width: 0 !important;
      min-height: 0 !important;
      padding: 0 !important;
    }

    /***** 3. Move window buttons into toolbar only when TST is visible *****/
    html#main-window[tabsintitlebar="true"] body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #TabsToolbar > .titlebar-buttonbox-container {
      display: block !important;
      position: absolute;
      top: 6px;   /* tweak these two to taste */
      left: 8px;
      z-index: 10;
    }

    /***** 4. Hide ONLY TST's sidebar header/title when TST is visible *****/
    html#main-window body:has(
      #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"][checked="true"]:not([hidden="true"])
    ) #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
      display: none !important;
    }

    /***** 5. Optional: small tab spacing if anything still renders tabs somewhere *****/
    .tab {
      margin-inline: 1px !important;
    }

    /***** 6. Optional: remove tiny vertical line from titlebar spacer (always) *****/
    #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar .titlebar-spacer {
      border-inline-end: none !important;
    }

    #sidebar-box {
      min-width: 100px !important;
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
