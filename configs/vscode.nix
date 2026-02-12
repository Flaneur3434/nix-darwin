{ config, pkgs, ... }:
{
  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions =
        with pkgs.vscode-extensions;
        [
          stkb.rewrap
          streetsidesoftware.code-spell-checker
          bbenoist.nix
          rust-lang.rust-analyzer
          arrterian.nix-env-selector
          ms-vscode.cpptools
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "magit";
            publisher = "kahole";
            version = "0.6.66";
            sha256 = "sha256-RLSb5OKWmSZB2sgi+YRkaOEaypI5hV6PGItqRw+ihts=";
          }
          {
            name = "find-it-faster";
            publisher = "tomrijndorp";
            version = "0.0.39";
            sha256 = "sha256-Rr1EKYSYmY52FfG4ClSQyikr0fd4cFKjphNxpzhiraw=";
          }
          {
            name = "vscode-emacs-friendly";
            publisher = "lfs";
            version = "0.9.0";
            sha256 = "sha256-YWu2a5hz0qGZvgR95DbzUw6PUvz17i1o4+eAUM/xjMg=";
          }
        ];

      userSettings = {
        "editor.minimap.autohide" = true;
        "files.insertFinalNewline" = true;
        "chat.commandCenter.enabled" = false;
        "editor.wordBasedSuggestions" = "allDocuments";
        "editor.rulers" = [ 80 ];
        "find-it-faster.general.useTerminalInEditor" = true;
        "find-it-faster.general.killTerminalAfterUse" = true;
        "find-it-faster.general.batTheme" = "Solarized (dark)";
        "git.blame.editorDecoration.enabled" = true;
        "nixEnvSelector.useFlakes" = true;
        "github.copilot.enable" = {
          "c" = false;
          "rust" = false;
          "nix" = false;
          "python" = false;
        };
        "editor.inlineSuggest.suppressSuggestions" = false;
        "[nix]" = {
          "editor.tabSize" = 2;
          "editor.insertSpaces" = true;
        };

        "terminal.integrated.shellIntegration.decorationsEnabled" = "never";
        "terminal.integrated.stickyScroll.enabled" = false;

        "extensions.ignoreRecommendations" = true;
        "terminal.integrated.macOptionIsMeta" = true;

        "editor.wordWrap" = false;
      };
      keybindings = [
        {
          key = "cmd+p";
          command = "find-it-faster.findFiles";
        }
        {
          key = "cmd+shift+f";
          command = "find-it-faster.findWithinFiles";
        }
      ];
    };
  };
}
