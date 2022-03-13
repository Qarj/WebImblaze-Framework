#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;
use File::Slurp;

$VERSION = '0.0.2';

local $| = 1; # don't buffer output to STDOUT

my $_text = read_file($ARGV[0]);

print $_text;