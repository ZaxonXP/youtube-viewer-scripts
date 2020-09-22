#!/usr/bin/perl

use warnings;
use strict;

while(<>) {

    s/-+\n//;
    s/Time: .*\n//;
    s/ID3 v.*\n//;
    s/(title|artist|album|recording date|release date|track)+.*\n//;
    s/.*WARNING: Non standard genre name.*\n//;

    print;
}
