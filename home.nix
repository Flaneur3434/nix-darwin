{
  config,
  pkgs,
  ...
}:
{
  home.stateVersion = "23.11";

  # Import submodules
  imports = [
    ./configs/zsh.nix
    ./configs/librewolf.nix
    ./configs/git.nix
    ./configs/ripgrep.nix
    ./configs/fzf.nix
    ./configs/bat.nix
    ./configs/karabiner-elements.nix
    ./configs/darwin-dock.nix
    ./configs/darwin-keybinds.nix
    ./configs/xe.nix
    ./configs/direnv.nix
  ];
}
