#!/usr/bin/perl

# Author: ZaxonXP45

# Script will use Discogs album version link to get the album data and then youtube-viewer to find the songs.
# It will produce the bash script which can be used to listen/download the music.
#
# the youtube-viewer.conf has following custom layout format
#
#
#  custom_layout_format  => [
#                            {width =>  10,    text => "*TIME* \| ", align => 'right'},
#                            {width => 13,    text => "*ID* \| "},
#                            {width => 13,    text => "*PUBLISHED* \| "},
#                            {width => '80%', text => "*TITLE*"},
#                           ],
#
# This has to be changed in the configuration file.

$| = 1;

use warnings;
use strict;

use 5.10.0;

use Encode;
use HTML::Entities;
use HTML::TreeBuilder;
use HTTP::Tiny;

# Definition of constants
use constant DIVIDER     => 60;
use constant TOLERANCE   => 10;
use constant SEARCH      => 'youtube-viewer --no-colors -noC --no-interactive --custom-layout';
use constant INTERACTIVE => 'youtube-viewer --resolution=audio --player=mpv_audio';
use constant PLAY        => 'youtube-viewer --resolution=audio --player=mpv_audio --no-interactive --std-input=1';

use constant YELLOW  => '\e[33m';
use constant GREEN   => '\e[32m';
use constant NORMAL  => '\e[39m';

################################################
# get html from url
sub get_html($) {
    my $url = shift;

    my $response = HTTP::Tiny->new->get($url);
    die "Failed!\n" unless $response->{success};
    return $response->{content} if length $response->{content};
}

################################################
# parse html and return the data hash
sub parse_html($) {
    my $html = shift;
    my %data;

    my $tree = HTML::TreeBuilder->new_from_content($html);

    my $tracklist = $tree->look_down("class", "playlist"); 

    my @records = $tracklist->look_down("class", "first tracklist_track track");
    @records    = (@records, $tracklist->look_down("class", " tracklist_track track"));

    foreach my $rec (@records) {
            
        my $nr     = $rec->look_down("class", "tracklist_track_pos")->as_text;
        my $artist = $rec->look_down("class", "tracklist_track_artists") ? $rec->look_down("class", "tracklist_track_artists")->as_text : $tree->look_down("id", "profile_title")->look_down("_tag", "a")->as_text;
        my $title  = $rec->look_down("class", "tracklist_track_title")->as_text;

        $nr = fix_nr($nr);

        # remove some garbage
        $artist = clean_garbage($artist);

        $data{$nr}{'artist'} = encode("utf-8", $artist);
        $data{$nr}{'title'}  = $title;
        $data{$nr}{'time'}   = $rec->look_down("class", "tracklist_track_duration")->as_text;

        if ($data{$nr}{'time'} eq '') {

            $data{$nr}{'time'} = "0:00";
        }

        $data{$nr}{'stime'}  = to_sec($data{$nr}{'time'});
    }

    return %data;
}

################################################
# clear the terminal screen
sub clear {
    print "\033[2J";    #clear the screen
    print "\033[0;0H";  #jump to 0,0
}

################################################
# clean the garbage from the string
sub clean_garbage($) {
    my $str = shift;

    $str =~ s/ \(\d\)//gi;
    $str =~ s/\s{2,}/ /gi;
    $str =~ s/\*//gi;
    $str =~ s/^[^\w]//i;

    return $str;
}

################################################
# fix number for some albums which has the strange notation
sub fix_nr($) {

    my $nr = shift;

    if ($nr =~ /(\d+)\.(\d+)/) {

        $nr = $1 + $2 - 1;
    }

    if ($nr =~ /\d+(\w+)/) {

        my $char = lc($1);
        my $idx = index('ABCDEFGHIJKLMNOPQRSTUVWXYZ', uc($char));

        if ($idx > -1) {
            $nr += $idx + 1;
        }
    }

    return $nr;
}

################################################
# quote dash sig in the string
sub quote_dash($) {
    my $str = shift;
    $str =~ s#\-#\\-#g;
    return $str;
}

################################################
# convert seconds to mm:ss
sub to_time($) {
    
    my $inp = shift;

    return sprintf("%d:%02d", int($inp / 60), $inp % 60);
}

################################################
# convert time string to seconds
sub to_sec($) {

    my $in = shift;
    my @parts = split(":", $in);
    my $sum;

    $sum = 3600 * $parts[0] + 60 * $parts[1] + $parts[2] if $#parts == 2;
    $sum =                    60 * $parts[0] + $parts[1] if $#parts == 1;
    
    return $sum;
}

###################################################
# get songs list
sub get_songs_list($) {

    my $title = shift;

    my @data;
    my $str = sprintf("%s \"%s\"", SEARCH, $title);
    
    # convert output into arary of hash table
    my @lines = qx/$str/;

    foreach (@lines) {
        chomp();

        next if (/^$/);
        next if (/.*LIVE.*/);

        my @out =  split(/\|/, $_);
        map { s/^\s+|\s+$| \-//g; } @out;   # trim the spaces and leading dash

        push(@data, { time => to_sec($out[0]), id => $out[1], title => $out[3] });
    }

    return @data;
}

###################################################
# prints playback script
sub print_playback_script {

    my ($play_str, $yt_id, $nr, $data, $out) = @_;

    no strict qw/refs/;

    printf($out "clear\n");
    printf($out "echo -e \"%s%s%s\"\n", YELLOW, "=" x DIVIDER, NORMAL);
    printf($out "echo -e \"%s%02d.%s - %s - %s%s\"\n", GREEN, $nr, 
                                                         $data->{$nr}{artist}, 
                                                         $data->{$nr}{title}, 
                                                         $data->{$nr}{time}, NORMAL);
    printf($out "echo -e \"%s%s%s\"\n", YELLOW, "=" x DIVIDER, NORMAL);

    if (defined($ENV{'DL'})) {

        printf($out "%s -d --filename=\"%02d.*TITLE*.*FORMAT*\" -- \"%s\"\n", $play_str, $nr, quote_dash($yt_id));
    } else {
        printf($out "%s -- \"%s\"\n", $play_str, quote_dash($yt_id));
    }
}

###################################################
# prints list file
sub print_list_file {
    my ($nr, $yt_id, $data, $out) = @_;

    no strict qw/refs/;

    printf($out "%4s | %s | %s | %s\n", $data->{$nr}{time}, 
                                        $yt_id, 
                                        $data->{$nr}{artist}, 
                                        $data->{$nr}{title}, 
          );


}

###################################################
# prints all the songs
sub print_all_songs(\@\%;$) {

    my ($ref_data, $ref_web, $out) = @_;
    my ($fout, $fout2, $out2);
    ($out2 = $out) =~ s/\.sh/.txt/;

    no strict qw/subs/;

    if (defined($out)) {

        #open($fout, ">$out") or die "Cannot create file \"$out\": $!\n";
        open($fout2, ">$out2") or die "Cannot create file \"$out2\": $!\n";

    } else {
        $fout=STDOUT;
        $fout2=STDOUT;
    }

    for ( my $i = 0; $i <= $#$ref_data; $i++ ) {
        
        #print_playback_script($ref_data->[$i][0], $ref_data->[$i][1], $ref_data->[$i][2], $ref_web, $fout);
        print_list_file($ref_data->[$i][2], $ref_data->[$i][1], $ref_web, $fout2);
    }

    #close($fout);
    close($fout2);
}

###################################################
# choose the song manually and return it
sub choose_song(\@$$$) {

    my ($data, $artist, $title, $time) = @_;
    my $str = "=" x DIVIDER;
    my $sel = 1;

    # print query data
    printf("%s\n%s - %s - %s\n%s\n", $str, $artist, $title, to_time($time), $str);

    # print all the data found
    for (my $i = 0; $i <= $#$data; $i++) {
        printf("%2d. %s - %s\n", $i+1, $data->[$i]{title}, to_time($data->[$i]{time}));
    }

    while(1) {
        printf("Choose: ");
        $sel = <STDIN>;
        chomp($sel);
        last if ($sel =~ m/[0-9]{1,2}/);
    }
    clear;

    return $data->[$sel-1]{id};
}

###################################################
# get the list of songs using youtube-viewer
sub get_songs(\%) {

    my $input = shift;
    my @ids;
    my $end_id = scalar keys %{$input};

    for (my $idx = 1; $idx <= $end_id; $idx++) {

        clear;
        printf("Getting info for song: %d / %d\n", $idx, $end_id); 

        # get song records from youtube-viewer by title and artist
        my $artist = $input->{$idx}{'artist'};
        my $title  = $input->{$idx}{'title'};
        my $time   = $input->{$idx}{'stime'};
        my $str    = $artist . " " . $title;

        my @data = get_songs_list($str);

        # If there is no time present, then always do the interactive
        if (! defined($time) && ! defined($ENV{'FIRST'}) ) {
            push(@ids, [INTERACTIVE, $str, $idx]);
            next;
        }

        my $found_id = undef;

        # search for the correct data (get closest time)
        foreach my $record (@data) { 

            my $rtitle = $record->{'title'};

            $rtitle =~ s/\&/and/gi;
            $artist =~ s/\&/and/gi;
            $title  =~ s/\&/and/gi;

            # 1) find the matching song title
            if ( index(lc($rtitle), lc($artist)) > -1) {

                # 2) check if the title is matching
                if ( index(lc($rtitle), lc($title)) > -1) {

                    my $rtime = $record->{'time'};
                
                    # if there is no time in the Discogs and the FIRST env var is used then use the first found
                    if (! defined($time) && defined($ENV{'FIRST'})) {

                        $found_id = $record->{id}; last;
                    } else {
                        # 3 check if time is close to expected
                        if ( $rtime == $time )                                      { $found_id = $record->{id}; last; } 
                        if ( ($rtime > $time) and (($rtime - $time) <= TOLERANCE) ) { $found_id = $record->{id}; last; }
                        if ( ($time > $rtime) and (($time - $rtime) <= TOLERANCE) ) { $found_id = $record->{id}; last; }
                    }
                }
            }
        }

        if ($found_id) {
            push(@ids, [PLAY, $found_id, $idx]);

        } else {
            push(@ids, [PLAY, choose_song(@data, $artist, $title, $time), $idx]);
        }
    }

    return @ids;
}

################################################
############# MAIN CODE ########################
################################################
if (@ARGV < 1) {
    print "Usage: $0 <discogs_album_version_url>\n";
    exit 1;
}

# create proper file name
my $file = $ARGV[0];
$file =~ s#https://www.discogs.com/([^/]+)/release/\d+#$1.sh#;
$file =~ s#(\d+)#sprintf("%03d", $1)#ge;

my $html  = get_html($ARGV[0]);      # get html from Discogs.org
my %web   = parse_html($html);       # create a data structure
my @sngs  = get_songs(%web);         # get records from youtube-viewer and print the script
print_all_songs(@sngs, %web, $file); # print the script to the file
chmod(0700, $file);                  # make the script executable
