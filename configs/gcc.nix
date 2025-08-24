{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

{
  options.programs.distributingGcc = {
    enable = mkEnableOption "Manage a prebuilt distributing-gcc tar.gz and add it to home.packages";

    url = mkOption {
      type = types.str;
      default = "";
      description = ''
        Full URL to the distributing-gcc tar.gz release asset.
        Example: https://github.com/simonjwright/distributing-gcc/archive/refs/tags/gcc-14.2.0-3-aarch64-cross.tar.gz
      '';
    };

    sha256 = mkOption {
      type = types.str;
      default = "0r5gd7cqgy0mvb7z6akj42qkwn92y2xvnc7ry0qyl9va0f9xzyn0";
      description = ''
        Base32 sha256 for the release asset. Use `nix-prefetch-url <url>` to obtain the correct hash
        and replace the default value.
      '';
    };
  };

  config = (mkIf (config.programs.distributingGcc.enable && config.programs.distributingGcc.url != "") {
    home.packages = (config.home.packages or [ ]) ++ [
      (pkgs.stdenv.mkDerivation {
        pname = "distributing-gcc";
        version = "unspecified";

        src = pkgs.fetchurl {
          url = config.programs.distributingGcc.url;
          sha256 = config.programs.distributingGcc.sha256;
        };

        buildPhase = ''
          # No build required; we only extract the prebuilt tree
          true
        '';

        installPhase = ''
          mkdir -p $out
          # Extract gzip tarball (.tar.gz/.tgz)
          if ! tar -xzf "$src" -C $out --strip-components=1; then
            tmpdir=$(mktemp -d)
            tar -xzf "$src" -C "$tmpdir"
            shopt -s dotglob 2>/dev/null || true
            mv "$tmpdir"/* "$out" || true
            rm -rf "$tmpdir"
          fi
        '';

        meta = with pkgs.lib; {
          description = "Prebuilt distributing-gcc extracted from a GitHub release tar.gz";
          maintainers = [ ];
          license = pkgs.lib.licenses.unfree;
        };
      })
    ];
  }) // {
    # Enable the program and provide sane defaults for URL and sha256 so the module
    # can be enabled directly by placing this file in `imports`.
    programs.distributingGcc.enable = mkDefault true;
    programs.distributingGcc.url = mkDefault "https://github.com/simonjwright/distributing-gcc/archive/refs/tags/gcc-14.2.0-3-aarch64-cross.tar.gz";
    programs.distributingGcc.sha256 = mkDefault "0r5gd7cqgy0mvb7z6akj42qkwn92y2xvnc7ry0qyl9va0f9xzyn0";
  };
}
