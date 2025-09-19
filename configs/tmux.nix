{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    mouse = true;
    keyMode = "emacs";
    historyLimit = 100000;
    
    plugins = with pkgs.tmuxPlugins; [
      # Optional: sensible defaults
      sensible
    ];

    # Add configuration for plugins
    extraConfig = ''
      
    '';
  };
}
