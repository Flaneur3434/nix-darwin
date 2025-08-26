{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    iterm2
  ];

  # iTerm2 Dynamic Profile in JSON format
  home.file."Library/Application Support/iTerm2/DynamicProfiles/nixprofile.json" = {
    text = builtins.toJSON {
      Profiles = [
        {
          Name = "Nix Managed Profile";
          Guid = "nix-default";

          "Option Key Sends" = 2; # Left Option = Esc+
          "Right Option Key Sends" = 2; # Right Option = Esc+

          # Text
          "Normal Font" = "Menlo 13";
          "ASCII Anti Aliased" = true;
          "Non Ascii Anti Aliased" = true;
          "Use Bold Font" = true;
          "Use Bright Bold" = true;

          # Window size settings
          Rows = 40;
          Columns = 120;

          # More history
          "Scrollback Lines" = 10000;

          # Bell so loud
          "Flashing Bell" = true;
          "Silence Bell" = true;

          # More color
          "Terminal Type" = "xterm-256color";

          "Close Sessions On End" = true;
          "Shell Integration Installed" = true;
          "Load Shell Integration Automatically" = true;
          # Prompt if running command
          "Prompt Before Closing 2" = 2;
          "Jobs to Ignore" = [
            "rlogin"
            "ssh"
            "slogin"
            "telnet"
          ];
        }
      ];
    };
  };

  # Global iTerm2 settings using targets.darwin.defaults
  targets.darwin.defaults."com.googlecode.iterm2" = {
    HideTab = false;
    HideScrollbar = true;
    PromptOnQuit = false;
    OpenNoWindowsAtStartup = false;
    CopySelection = true;
    # Compact tab configuration
    TabStyleWithAutomaticOption = 6;
    # Open TMUX window in new native windows
    OpenTmuxWindowsIn = 0;
    # Enable arrow keys when scrolling in alternate screen mode
    AlternateMouseScroll = true;
    # Set the default profile
    "Default Bookmark Guid" = "nix-default";
  };
}
