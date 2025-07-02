{
  config,
  pkgs,
  ...
}:
{
  home.stateVersion = "23.11";

  # Import submodules
  imports = [
    ./configs/tmux.nix
    ./configs/zsh.nix
    ./configs/librewolf.nix
    ./configs/vscode.nix
    ./configs/git.nix
    ./configs/ripgrep.nix
    ./configs/fzf.nix
    ./configs/bat.nix
    ./configs/iterm2.nix
    ./configs/karabiner-elements.nix
    ./configs/darwin-dock.nix
    ./configs/xe.nix
    ./configs/direnv.nix
  ];
}
