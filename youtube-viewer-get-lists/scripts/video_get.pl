#!/usr/bin/perl

use warnings;
use strict;
use Term::ANSIColor;

$| = 1;

my ($in, $count, $after) = @ARGV;

if ($#ARGV == 0) {
    printf("How many to get? ");
    $count = <STDIN>;
    chomp($count);
}

if ($count eq "a") {
    $count = qx/cat $in | wc -l/;
    chomp($count);
}

my $file = open(IN,"-|", "tac", "$in") or die "Cannot open file '$in'; $!\n";

while(<IN>) {

    chomp();
    $after--;

    if ($after < 0) {

        my $cmd = sprintf("youtube-dl -f 'best[height<=?720]/best[width\=?1280]' -o '%s' -- %s", '%(upload_date)s.%(title)s.%(ext)s', (split(" ", $_))[2]);

        printf("\n[%4d] %s\n", $count, colored("$cmd\n", 'green'));
        system $cmd;

        $count--;

        last if ! $count;
    }
}
close(IN);
