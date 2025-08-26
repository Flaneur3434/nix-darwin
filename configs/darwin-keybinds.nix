{ config, pkgs, ... }:
{
  targets.darwin.keybindings = {
    # Emacs-like keybindings for word movement and deletion

    "~f" = "moveWordForward:"; # Option-f: move forward one word
    "~b" = "moveWordBackward:"; # Option-b: move backward one word
    "~d" = "deleteWordForward:"; # Option-d: delete word forward
    "~^H" = "deleteWordBackward:"; # Option-delete: delete word backward (using Control-H for backspace)
    "~\\U007F" = "deleteWordBackward:"; # Option-delete: alternative using explicit delete key code

    # Other common Emacs keybindings (optional)

    "^a" = "moveToBeginningOfLine:"; # Control-a: move to beginning of line
    "^e" = "moveToEndOfLine:"; # Control-e: move to end of line
    "^k" = "deleteToEndOfLine:"; # Control-k: delete to end of line
    "^y" = "yank:"; # Control-y: paste (yank)
    "^w" = "cut:"; # Control-w: cut (kill region)
    "^ " = "setMark:"; # Control-space: set mark
    "^\U0000" = "setMark:"; # Control-space: alternative (using explicit null char)

    # Line movement with selection
    "^$a" = "moveToBeginningOfLineAndModifySelection:"; # Control-Shift-a: select to beginning of line
    "^$e" = "moveToEndOfLineAndModifySelection:"; # Control-Shift-e: select to end of line
  };
}
