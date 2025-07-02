{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;

    # Your user information (update these)
    userName = "Your Name";
    userEmail = "your.email@example.com";

    # Aliases
    aliases = {
      a = "add -v";
      c = "commit -m";
      b = "branch";
      sw = "switch";
      fp = "push --force-with-lease";
      s = "status";
    };

    # Optional: Additional git settings
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;

      # Better diffs
      diff.algorithm = "histogram";

      # Use delta for better diffs (optional)
      # core.pager = "delta";

      core.editor = "code --wait"; # or your preferred editor
    };
  };

  # Optional: Install delta for better git diffs
  # home.packages = with pkgs; [
  #   delta
  # ];
}
