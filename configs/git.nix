{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Your Name";
        email = "your.email@example.com";
      };

      # Aliases
      aliases = {
        a = "add -v";
        cm = "commit -m";
        ca = "commit --amend";
        b = "branch";
        sw = "switch";
        fp = "push --force-with-lease";
        s = "status";
        g = "log --date=format:%Y-%m-%dT%H:%M --format='%C(auto)%h -%d %s %Cgreen(%cd) %C(bold blue)<%an>%Creset' --graph";
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

        core.editor = "code --wait";
      };
    };
  };

  # Optional: Install delta for better git diffs
  # home.packages = with pkgs; [
  #   delta
  # ];
}
