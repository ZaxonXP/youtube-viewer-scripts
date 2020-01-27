# youtube-viewer-scripts
Here are some Bash/Perl scripts which allow to extend youtube-viewer functionality:

1) `discogs_url_to_youtube-viewer_parser.pl` - allows to specify Discogs.com album url to get a list of Youtube IS's in the list acceptable by gapless playback.
2) `gapless_play.sh` - uses a list of YT ID's to play music without gaps.
3) `gapless_play_pause.sh` - allows the play/pause currently used MPV player instance.
4) `monitor_gapless_play.sh` - displays in a separate xterm currently played song info.

Dependencies:

These scripts depends on the following items:

a) `youtube-viewer` script has to be installed https://github.com/trizen/youtube-viewer

b) Perl modules has to be on the machine running the Perl script:

```
use HTML::Entities;
use HTML::TreeBuilder;
use HTTP::Tiny;
```
c) MPV player is used for playback

d) Bash and some standard Linux tools.
