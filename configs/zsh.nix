{ config, pkgs, ... }:
let
  history_size = 10000;
  username = "johndoe";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    historySubstringSearch.enable = true;

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # Default theme, change to your preference

      # Popular plugins
      plugins = [
        "macos"
        "history-substring-search"
      ];
    };

    history = {
      size = history_size;
      save = history_size;
      append = true;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = false;
    };

    # need to run `source ~/.zshrc` after nix switch command
    shellAliases = {

    };

    sessionVariables = {
      EDITOR = "mg";
      VISUAL = "code --wait";
    };

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="/Users/${username}/.local/bin:$PATH"

      # GCC 14.2.0 with ADA support enabled
      export PATH="/opt/gcc-14.2.0-3-aarch64/bin:$PATH"
    '';

    initContent = ''
      # Disable flow control to free up Ctrl+S
        stty -ixon
        
        # Enable Emacs key bindings
        bindkey -e
        
        # Additional useful Emacs-style bindings
        bindkey '^A' beginning-of-line
        bindkey '^E' end-of-line
        bindkey '^K' kill-line
        bindkey '^U' backward-kill-line
        bindkey '^W' backward-kill-word
        bindkey '^[b' backward-word  # Alt+b
        bindkey '^[f' forward-word   # Alt+f
        bindkey '^[d' kill-word      # Alt+d
        bindkey '^Y' yank
        bindkey '^R' history-incremental-search-backward
        bindkey '^S' history-incremental-search-forward
        bindkey '^P' up-line-or-history
        bindkey '^N' down-line-or-history

        # Now, override the default fzf bindings to match Emacs isearch
        # Note: fzf's bindings are typically done with `fzf-mode` widgets.
        if [[ -n "$fzf-history-widget" ]]; then
          bindkey '^R' fzf-history-widget
        fi

        # Case-insensitive tab completion
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

        # Additional completion improvements
        zstyle ':completion:*' menu select
    '';
  };
}
