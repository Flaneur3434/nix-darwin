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
    ./configs/gcc.nix
  ];

  # Enable locally-provided distributing-gcc package
  programs.gcc = {
    enable = true;
    url = "https://github.com/simonjwright/distributing-gcc/archive/refs/tags/gcc-14.2.0-3-aarch64-cross.tar.gz";
    # sha256 obtained from a local nix-prefetch-url run
    sha256 = "0r5gd7cqgy0mvb7z6akj42qkwn92y2xvnc7ry0qyl9va0f9xzyn0";
  };
}
