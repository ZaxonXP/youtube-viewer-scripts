# youtube-viewer-scripts
Here are some Bash/Perl scripts which allow to extend youtube-viewer functionality:

1) `discogs_url_to_youtube-viewer_parser.pl` - allows to specify Discogs.com album url to get a list of Youtube IS's in the list acceptable by gapless playback.
2) `gapless_play.sh` - uses a list of YT ID's to play music without gaps.
3) `gapless_play_pause.sh` - allows the play/pause currently used MPV player instance.
4) `monitor_gapless_play.sh` - displays in a separate xterm currently played song info.

### Dependencies:

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

### Usage

1) Put these scripts somewhere where your PATH can see them. :)
2) Modify the `youtube-viewer.conf` custom_layout to this:

```
  custom_layout_format  => [
                            {width =>  10,    text => "*TIME* \| ", align => 'right'},
                            {width => 13,    text => "*ID* \| "},
                            {width => 13,    text => "*PUBLISHED* \| "},
                            {width => '80%', text => "*TITLE*"},
                           ],

```

3) Run `discogs_url_to_youtube-viewer_parser.pl <album_version_URL>` to get a file with the album info. In case the file does not have the ID's you need to find them yourself as the maching mechanism might not find the album all the time.

4) Run `gapless_play.sh <album_file.txt>` to play the album music without gaps (it will run two instances of mpv, second paused but caching the next song).

5) You can bind some key combination to `gapless_play_pause.sh` in order to play/pause currently used MPV instance.

6) `monitor_gapless_play.sh` will be opened to display the currently played song info.
