#!/usr/bin/perl

use warnings;
use strict;

if ($#ARGV != 1) {
    print "Get the Youtube videos from the provided playlist ID\n\n";
    print "$0 <playlistID> <output_file>\n\n";
    exit 0;
}

my ($chID, $out) = @ARGV;
my $i = 1;

open(OUT, ">$out") or die "Cannot create output file: $!\n";

while (1) {
    my @lines = qx#youtube-viewer --no-interactive --custom-layout --page=$i "https://www.youtube.com/playlist?list=$chID"#;

    last if ($#lines == -1);

    foreach (@lines) {

        s/^(\d{2}:\d{2}) /00:$1 /;
        
        if ($_ !~ m/^$/) {
        
            print $_;
            print OUT $_;
        };
    }

    $i++;
}
close(OUT);
