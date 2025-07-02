{ config, pkgs, ... }:
{
  programs.direnv = {
    enable = true;
    # This enables the 'use nix' directive in your .envrc files,
    # allowing direnv to load environments from Nix flakes.
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
