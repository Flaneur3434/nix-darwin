{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.gcc;
in
{
  options.programs.gcc = {
    enable = mkEnableOption "Manage a prebuilt distributing-gcc tar.xz and add it to home.packages";

    url = mkOption {
      type = types.str;
      default = "";
      description = ''
      	Full URL to the distributing-gcc tar.xz release asset.
      	Example: https://github.com/simonjwright/distributing-gcc/releases/download/vX.Y.Z/gcc-aarch64-apple-darwin.tar.xz
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

  config = mkIf (cfg.enable && cfg.url != "") {
    home.packages = (config.home.packages or [ ]) ++ [
      (pkgs.stdenv.mkDerivation {
        pname = "distributing-gcc";
        version = "unspecified";

        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
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
          description = "Prebuilt distributing-gcc extracted from a GitHub release tar.xz";
          maintainers = with maintainers; [ ];
          license = licenses.unfree;
        };
      })
    ];
  };
}
