{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    mouse = true;
    keyMode = "emacs";

    plugins = with pkgs.tmuxPlugins; [
      # Pain Control provides intuitive bindings for pane navigation
      pain-control

      # Optional: sensible defaults
      sensible
    ];

    extraConfig = ''
      # Set option key as Meta (Alt)
      set-option -g xterm-keys on

      # macOS specific: ensure Option key works as Meta
      set -s escape-time 0

      set -g history-limit 10000
      bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"
    '';
  };
}
