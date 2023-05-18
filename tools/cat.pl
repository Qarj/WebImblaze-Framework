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
use File::Slurp;  ## no critic (DiscouragedModules)

$VERSION = '0.0.2';

local $| = 1; # don't buffer output to STDOUT

my $_text = read_file($ARGV[0]);

print $_text;