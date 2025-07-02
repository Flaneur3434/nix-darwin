{ config, pkgs, ... }:
{
  targets.darwin.defaults = {
    "com.apple.dock" = {
      # removed pinned apps
      "persistent-apps" = [ ];
      "persistent-others" = [ ];

      # hide recent apps section
      "show-recents" = false;

      # dock behavior
      "autohide" = true;

      # dock icon size
      "tilesize" = 48;
    };
  };
}
