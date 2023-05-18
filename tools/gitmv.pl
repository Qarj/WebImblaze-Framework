#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$
# -*- coding: utf-8 -*-
# perl

use v5.16;
use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.0.2';

my $src =$ARGV[0];
my $dest = $ARGV[1];

if (not defined $dest) {
    die 'Usage: gitmv.pl source dest';
}

my @src_files = glob $src;

foreach (@src_files) {
    my $result = `git mv $_ $dest`;
    print "$_ -> $dest\n";
}

