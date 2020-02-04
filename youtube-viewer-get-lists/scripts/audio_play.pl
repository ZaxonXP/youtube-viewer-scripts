#!/usr/bin/perl

use warnings;
use strict;
use Term::ANSIColor;

$| = 1;

my ($in, $count) = @ARGV;

if ($#ARGV == 0) {
    printf("How many to play? ");
    $count = <STDIN>;
    chomp($count);
}

# count all entries
if ($count eq "a") {
    $count = qx/cat $in | wc -l/;
    chomp($count);
}

my $file = open(IN,"-|", "tac", "$in") or die "Cannot open file '$in'; $!\n";

while(<IN>) {

    chomp();

    my $cmd = sprintf("youtube-viewer -C --use-colors -A --player=mpv_audio --no-interactive --resolution=audio https://www.youtube.com/watch?v=%s", (split(" ", $_))[2]);

    printf("\n[%4d] %s\n", $count, colored("$cmd\n", 'green'));
    system $cmd;

    $count--;

    last if ! $count;
}
close(IN);
