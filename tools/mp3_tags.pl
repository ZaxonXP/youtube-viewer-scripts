#!/usr/bin/perl
use warnings;
use strict;
use Text::ANSITable;
no warnings qw{qw};

my $inp = $ARGV[0] || '*.mp3';
$inp =~ s/(\s)/\\$1/g;

my @list = qx#eyeD3 --no-color -l error $inp#;
chomp(@list);

my %data; 
my $nr = 0;
my @headers  = qw(artist album track tracks year genre title size file );
my @headers2 = qw(artist album     #     TR year genre title size file );

foreach my $line (@list) {

    next if ($line =~ m/^-+$/);

    if ($line =~ m#([^/]*\.mp3).*\[ (\d*\.\d* (K|M)B) \]#) {
        $nr++;
        $data{$nr}{'file'} = $1;
        $data{$nr}{'size'} = $2;
    }

    if ($line =~ m#title: (.*)#)     { $data{$nr}{'title'}  = $1; }
    if ($line =~ m#^artist: (.*)#)   { $data{$nr}{'artist'} = $1; }
    if ($line =~ m#album: (.*)#)     { $data{$nr}{'album'}  = $1; }

    if ($line =~ m#(release|recording) date: (.*)#){ 
        $data{$nr}{'year'}   = $2; 
    }
    
    if ($line =~ m#track: (\d+)/(\d+).*genre:\s+([\w\s]+)#)  { 
        $data{$nr}{'track'} = $1; 
        $data{$nr}{'tracks'} = sprintf("%02d", $2); 
        $data{$nr}{'genre'} = $3;
    }
    
    if ($line =~ m#track:.*genre:\s+([\w\s]+)#)  { 
        $data{$nr}{'genre'} = $1;
    }
}

my $t = Text::ANSITable->new( 'use_box_chars' => 1, 'use_utf8' => 1, cell_pad => 1);

$t->border_style('Default::bold');
$t->columns(\@headers2);
$t->set_column_style('size', align => 'right');

foreach my $key (sort { $a <=> $b } keys(%data)) {

    my @row;
    foreach my $att (@headers) {
        push(@row, $data{$key}{$att});
    }
    
    if ($key%2) {
        $t->add_row(\@row, { bgcolor => '202020'});
    } else {
        $t->add_row(\@row);
    }
}

binmode(STDOUT, ":utf8");
print $t->draw;
<STDIN>;
