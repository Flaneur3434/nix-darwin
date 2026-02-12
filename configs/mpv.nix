{ config, pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    # Usually just pkgs.mpv is fine on macOS
    package = pkgs.mpv;

    # mpv.conf options (see next section)
    config = {
      profile = "gpu-hq";          # nice defaults for quality
      vo = "gpu-next";             # modern GPU video output
      hwdec = "auto-safe";         # use GPU decoding (videotoolbox on mac)

      keep-open = "yes";           # keep window open at end of file
      save-position-on-quit = "yes"; # resume from last position

      # Subtitles
      sub-auto = "fuzzy";          # auto-load subs with similar name
      sub-font-size = "48";

      # Higher volume headroom
      volume-max = "200";

      # Youtube / network video quality
      ytdl-format = "bestvideo+bestaudio/best";

      # Use yt-dlp from PATH (installed via Nix: pkgs.yt-dlp)
      "script-opts" = "ytdl_hook-ytdl_path=yt-dlp";

      # Slightly bigger OSD and seekbar
      osd-font-size = "28";
      osd-duration = "1500";
      osd-bar = "yes";

      # Cache (helps with network/remote media)
      cache = "yes";
      demuxer-max-bytes = "400M";
      demuxer-max-back-bytes = "100M";



      # Screenshots
      screenshot-directory = "~/Pictures/mpv";
      screenshot-format = "png";
      screenshot-template = "%F-%P";
    };

    # input.conf / keybindings
    bindings = {
      # Playback control
      "SPACE" = "cycle pause";
      "p"     = "cycle pause";

      # Seeking
      "LEFT"  = "seek -5";
      "RIGHT" = "seek 5";
      "UP"    = "seek 60";
      "DOWN"  = "seek -60";

      # Speed control
      "["     = "add speed -0.1";
      "]"     = "add speed 0.1";
      "BS"    = "set speed 1.0";

      # Volume
      "9"     = "add volume -5";
      "0"     = "add volume 5";

      # Playlist
      ">"     = "playlist-next";
      "<"     = "playlist-prev";

      # Screenshots
      "s"     = "screenshot";        # normal
      "S"     = "screenshot window"; # whole window (with OSD)

      # Toggle stats & OSD
      "i"     = "show-text \"\${filename}\"";
      "TAB"   = "script-binding stats/display-stats-toggle";

      # Quit
      "q"     = "quit";
      "Q"     = "quit-watch-later"; # remember position
    };

    # (Optional) Lua scripts managed by Nix:
    # these live in ~/.config/mpv/scripts
    scripts = with pkgs.mpvScripts; [
      uosc          # modern minimal UI (timeline, buttons, etc.)
      sponsorblock  # auto-skip sponsored segments on YouTube
      thumbfast     # fast thumbnail previews on seekbar (used by uosc)
    ];
  };
}
