#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;
use File::Copy qw(copy), qw(move);

$VERSION = '0.01';

local $| = 1; # don't buffer output to STDOUT

my $source_pattern = $ARGV[0];
$source_pattern =~ s/\\/\\\\/g;
my @source = glob($source_pattern);

my $dest = $ARGV[1];
$dest =~ s/\\/\\\\/g;

foreach (@source) {
    copy $_, $dest;
    print "Copied $_ to $dest\n";
}