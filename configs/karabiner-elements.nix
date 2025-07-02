{ config, pkgs, ... }:

let
  # Common bundle identifiers to exclude from Emacs keybindings
  excludedApps = [
    "^com\\.googlecode\\.iterm2$"
    "^com\\.apple\\.Terminal$"
    "^org\\.gnu\\.Emacs$"
    "^com\\.microsoft\\.VSCode$"
  ];

  # Helper function to create a basic keybinding manipulator
  mkKeybinding =
    {
      description,
      from,
      to,
      conditions ? [
        {
          type = "frontmost_application_unless";
          bundle_identifiers = excludedApps;
        }
      ],
      to_after_key_up ? null,
    }:
    {
      inherit description;
      type = "basic";
      inherit from to;
      inherit conditions;
    }
    // (if to_after_key_up != null then { inherit to_after_key_up; } else { });

  # Helper function for simple key-to-key mappings
  mkSimpleKeybinding =
    {
      description,
      fromKey,
      fromMods,
      toKey,
      toMods ? [ ],
    }:
    mkKeybinding {
      inherit description;
      from = {
        key_code = fromKey;
        modifiers = {
          mandatory = fromMods;
        };
      };
      to = [
        {
          key_code = toKey;
          modifiers = toMods;
        }
      ];
    };

  # Helper function for multi-step keybindings (like case conversion)
  mkMultiStepKeybinding =
    {
      description,
      fromKey,
      fromMods,
      steps,
    }:
    mkKeybinding {
      inherit description;
      from = {
        key_code = fromKey;
        modifiers = {
          mandatory = fromMods;
        };
      };
      to = steps;
    };

  # Search keybindings (Version 2 - Stateful)
  searchKeybindings = [
    # Ctrl+S → Open search (first time)
    {
      type = "basic";
      from = {
        key_code = "s";
        modifiers = {
          mandatory = [ "control" ];
        };
      };
      to = [
        {
          key_code = "f";
          modifiers = [ "command" ];
        }
      ];
      to_after_key_up = [
        {
          set_variable = {
            name = "in_search_mode";
            value = 1;
          };
        }
      ];
      conditions = [
        {
          type = "frontmost_application_unless";
          bundle_identifiers = excludedApps;
        }
        {
          type = "variable_unless";
          name = "in_search_mode";
          value = 1;
        }
      ];
    }
    # Ctrl+S → Find next (when already in search)
    {
      type = "basic";
      from = {
        key_code = "s";
        modifiers = {
          mandatory = [ "control" ];
        };
      };
      to = [
        {
          key_code = "g";
          modifiers = [ "command" ];
        }
      ];
      conditions = [
        {
          type = "frontmost_application_unless";
          bundle_identifiers = excludedApps;
        }
        {
          type = "variable_if";
          name = "in_search_mode";
          value = 1;
        }
      ];
    }
    # Ctrl+R → Search backward
    {
      type = "basic";
      from = {
        key_code = "r";
        modifiers = {
          mandatory = [ "control" ];
        };
      };
      to = [
        {
          key_code = "g";
          modifiers = [
            "command"
            "shift"
          ];
        }
      ];
      to_after_key_up = [
        {
          set_variable = {
            name = "in_search_mode";
            value = 1;
          };
        }
      ];
      conditions = [
        {
          type = "frontmost_application_unless";
          bundle_identifiers = excludedApps;
        }
      ];
    }
    # Escape to exit search mode
    {
      type = "basic";
      from = {
        key_code = "escape";
      };
      to = [
        {
          key_code = "escape";
        }
      ];
      to_after_key_up = [
        {
          set_variable = {
            name = "in_search_mode";
            value = 0;
          };
        }
      ];
    }
    # Terminal-specific: preserve native Ctrl+R
    {
      type = "basic";
      from = {
        key_code = "r";
        modifiers = {
          mandatory = [ "control" ];
        };
      };
      to = [
        {
          key_code = "r";
          modifiers = [ "control" ];
        }
      ];
      conditions = [
        {
          type = "frontmost_application_if";
          bundle_identifiers = [
            "^com\\.googlecode\\.iterm2$"
            "^com\\.apple\\.Terminal$"
            "^net\\.kovidgoyal\\.kitty$"
          ];
        }
      ];
    }
  ];

  # Word navigation keybindings
  wordNavigation = [
    (mkSimpleKeybinding {
      description = "Option+f -> Move word forward";
      fromKey = "f";
      fromMods = [ "option" ];
      toKey = "right_arrow";
      toMods = [ "option" ];
    })
    (mkSimpleKeybinding {
      description = "Option+b -> Move word backward";
      fromKey = "b";
      fromMods = [ "option" ];
      toKey = "left_arrow";
      toMods = [ "option" ];
    })
    (mkSimpleKeybinding {
      description = "Option+d -> Delete word forward";
      fromKey = "d";
      fromMods = [ "option" ];
      toKey = "delete_forward";
      toMods = [ "option" ];
    })
    (mkSimpleKeybinding {
      description = "Option+delete -> Delete word backward";
      fromKey = "delete_or_backspace";
      fromMods = [ "option" ];
      toKey = "delete_or_backspace";
      toMods = [ "option" ];
    })
  ];

  # Paragraph navigation keybindings
  paragraphNavigation = [
    (mkSimpleKeybinding {
      description = "Option+{ -> Beginning of paragraph";
      fromKey = "open_bracket";
      fromMods = [
        "option"
        "shift"
      ];
      toKey = "up_arrow";
      toMods = [ "option" ];
    })
    (mkSimpleKeybinding {
      description = "Option+} -> End of paragraph";
      fromKey = "close_bracket";
      fromMods = [
        "option"
        "shift"
      ];
      toKey = "down_arrow";
      toMods = [ "option" ];
    })
  ];

  # Case conversion keybindings
  caseConversion = [
    (mkMultiStepKeybinding {
      description = "Option+u -> Uppercase word";
      fromKey = "u";
      fromMods = [ "option" ];
      steps = [
        {
          key_code = "right_arrow";
          modifiers = [
            "option"
            "shift"
          ];
        }
        {
          key_code = "u";
          modifiers = [
            "control"
            "command"
          ];
        }
      ];
    })
    (mkMultiStepKeybinding {
      description = "Option+l -> Lowercase word";
      fromKey = "l";
      fromMods = [ "option" ];
      steps = [
        {
          key_code = "right_arrow";
          modifiers = [
            "option"
            "shift"
          ];
        }
        {
          key_code = "l";
          modifiers = [
            "control"
            "command"
          ];
        }
      ];
    })
    (mkMultiStepKeybinding {
      description = "Option+c -> Capitalize word";
      fromKey = "c";
      fromMods = [ "option" ];
      steps = [
        {
          key_code = "right_arrow";
          modifiers = [
            "option"
            "shift"
          ];
        }
        {
          key_code = "c";
          modifiers = [
            "control"
            "command"
          ];
        }
      ];
    })
  ];

  # Page navigation keybindings
  pageNavigation = [
    (mkSimpleKeybinding {
      description = "Ctrl+v -> Page down";
      fromKey = "v";
      fromMods = [ "control" ];
      toKey = "page_down";
    })
    (mkSimpleKeybinding {
      description = "Option+v -> Page up";
      fromKey = "v";
      fromMods = [ "option" ];
      toKey = "page_up";
    })
  ];

  # Document navigation keybindings
  documentNavigation = [
    (mkSimpleKeybinding {
      description = "Option+< -> Beginning of document";
      fromKey = "comma";
      fromMods = [
        "option"
        "shift"
      ];
      toKey = "home";
      toMods = [ "command" ];
    })
    (mkSimpleKeybinding {
      description = "Option+> -> End of document";
      fromKey = "period";
      fromMods = [
        "option"
        "shift"
      ];
      toKey = "end";
      toMods = [ "command" ];
    })
  ];

  # Undo keybindings
  undoKeybindings = [
    (mkSimpleKeybinding {
      description = "Ctrl+_ -> Undo";
      fromKey = "hyphen";
      fromMods = [
        "control"
        "shift"
      ];
      toKey = "z";
      toMods = [ "command" ];
    })
    (mkSimpleKeybinding {
      description = "Ctrl+/ -> Undo";
      fromKey = "slash";
      fromMods = [ "control" ];
      toKey = "z";
      toMods = [ "command" ];
    })
  ];

  # Group keybindings into rules
  emacsRules = [
    {
      description = "Emacs Search (Ctrl+S/R)";
      manipulators = searchKeybindings;
    }
    {
      description = "Emacs Word Navigation";
      manipulators = wordNavigation;
    }
    {
      description = "Emacs Paragraph Navigation";
      manipulators = paragraphNavigation;
    }
    {
      description = "Emacs Case Conversion";
      manipulators = caseConversion;
    }
    {
      description = "Emacs Page Navigation";
      manipulators = pageNavigation;
    }
    {
      description = "Emacs Document Navigation";
      manipulators = documentNavigation;
    }
    {
      description = "Emacs Undo";
      manipulators = undoKeybindings;
    }
  ];

  # Generate the Karabiner configuration
  karabinerConfig = {
    global = {
      ask_for_confirmation_before_quitting = true;
      check_for_updates_on_startup = true;
      show_in_menu_bar = true;
      show_profile_name_in_menu_bar = false;
    };

    profiles = [
      {
        name = "Default";
        selected = true;
        simple_modifications = [ ];

        complex_modifications = {
          rules = emacsRules;
        };

        # Set keyboard type to ANSI to prevent setup dialog
        virtual_hid_keyboard = {
          country_code = 0;
          keyboard_type_v2 = "ansi";
        };
      }
    ];
  };

in
{
  # Note: karabiner-elements installed via Homebrew, not nixpkgs

  # Create the karabiner directory structure with generated config
  home.file.".config/karabiner/karabiner.json" = {
    text = builtins.toJSON karabinerConfig;
    force = true; # Force overwrite without backing up
    onChange = ''
      # More robust Karabiner restart script
      /bin/launchctl bootout gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server 2>/dev/null || true
      sleep 1
      /bin/launchctl bootstrap gui/`id -u` /Library/LaunchAgents/org.pqrs.karabiner.karabiner_console_user_server.plist 2>/dev/null || true
      /bin/launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server 2>/dev/null || true
    '';
  };

  # Ensure the assets directory exists (for complex modifications)
  home.file.".config/karabiner/assets/complex_modifications/.keep".text = "";
}
