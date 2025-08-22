{
  description = "Nix Darwin flake to setup Home Manager and packages";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nur.url = "github:nix-community/NUR";
  };
  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      mac-app-util,
      nur,
      ...
    }:
    let
      username = "johndoe";
      configuration =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        {
          # Set the primary user for nix-darwin
          system.primaryUser = username;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment = {
            systemPackages = [
              pkgs.mg
              pkgs.nixfmt-rfc-style
            ];

            variables = {
              EDITOR = "gui-emacs";
            };
          };

          # Allow only specific unfree packages
          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "vscode"
              "discord"
            ];

          # Import system level configurations
          imports = [
            ./configs/homebrew.nix
          ];

          # Add pkg overlays
          nixpkgs.overlays = [
            nur.overlays.default # Nix User Repository
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;
          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          (
            { config, pkgs, ... }:
            {
              users.users.${username} = {
                name = username;
                home = "/Users/${username}";
                shell = pkgs.zsh;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = {
                imports = [
                  ./home.nix
                  mac-app-util.homeManagerModules.default
                ];
              };
            }
          )
        ];
      };
    };
}
