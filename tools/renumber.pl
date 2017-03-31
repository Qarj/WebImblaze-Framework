#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.02';

#Takes a test case file, and renumbers it
#Starts numbering from 10
#Each time we hit a section break, we increase to the nearest 100 e.g. 220 will go to 300, however:
#   - The first test step is a special case - this logic will not be applied
#   - Due to the way this is implemented, 290 will go to 400, since the calculation is based on the next id which is 300

# Limitations
#
# 1. only id="" recognised, not id='' or id = ""
# 2. if you have an id="5" inside your postbody or elsewhere, it will get renumbered too

#Argument 0 is the testcase.xml file to renumber

my $file_full = $ARGV[0];

open my $INFILE, '<', $file_full or die "Could not open $file_full for reading!\n";
my @lines = <$INFILE>;
close $INFILE;

my $new_id=10;
my $inc=10;

foreach my $line (@lines) {
    
    #Renumber the id
    if ($line =~ m{id="([\d]+)"}) { #look for the id
        #my $id = $1; #just for testing purposes
        #print "id = $id \n"; #debug
        $line =~ s{id="([\d]+)"}{id="$new_id"};
        print "$1 now $new_id\n";
        update_retryfromstep($1, $new_id);
        $new_id=$new_id+$inc;
    };
    
    #If we find a section break, then increment up to the nearest 100
    if ($line =~ m{section="([^"]*)"}) { #" look for the id
        if ($new_id > 10) {#Ignore this rule if the section break is on the first test step
            $new_id=int(($new_id+100)/100)*100;
        }
    };
    
}

open my $OUTFILE, '>', $file_full or die "Could not open $file_full for writing!\n";
foreach my $line (@lines) {
    $line =~ s{retryfromstep="_}{retryfromstep="}; # remove retryfromstep multi-update protection
    #print $line;
    print {$OUTFILE} $line;
}
close $OUTFILE;

#------------------------------------------------------------------
sub update_retryfromstep {
    my ($_old, $_new) = @_;

    foreach (@lines) {
        if ($_ =~ m{retryfromstep="$_old"}) {
            $_ =~ s{retryfromstep="$_old"}{retryfromstep="_$_new"}; # put a protection on so the retryfromstep is only updated once
            print qq|    retryfromstep="$_old" now retryfromstep="$_new"\n|;
        }
    }

    return;
}