#!/usr/bin/perl
use strict;
use warnings;

our $VERSION = 0.01;

#    WebInjectFramework is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    WebInjectFramework is distributed in the hope that it will be useful,
#    but without any warranty; without even the implied warranty of
#    merchantability or fitness for a particular purpose.  See the
#    GNU General Public License for more details.



my ( $opt_version, $opt_target, $opt_batch, $opt_help );

use Getopt::Long;

$| = 1; #don't buffer output to STDOUT

engine();

#------------------------------------------------------------------
sub engine {

    getoptions();  #get command line options

    return;
}

#------------------------------------------------------------------
sub getoptions {  #shell options
        
    Getopt::Long::Configure('bundling');
    GetOptions(
        't|target=s'  => \$opt_target,
        'b|batch=s'   => \$opt_batch,
        'v|V|version' => \$opt_version,
        'h|help'      => \$opt_help,
        ) 
        or do {
            print_usage();
            exit();
        };
    if ($opt_version) {
        print_version();
        exit;
    }
    
    if ($opt_help) {
        print_version();
        print_usage();
        exit;
    }

    if (($#ARGV + 1) < 1) {
        print STDOUT "\nERROR: No test file name given\n";
        print_usage();
        exit;
    }
    
    if (!defined $opt_target) {
        print STDOUT "\nERROR: Target environment handle must be specified\n";
        print_usage();
        exit;
    }
    return;
}

sub print_version {
    print "\nWebInjectFramework version $VERSION\nFor more info: https://github.com/Qarj/WebInjectFramework\n\n";
    return;
}

sub print_usage {
    print <<'EOB'

Usage: RunTest.pl <<options>>

-t|--target target environment handle                      -t skynet
-b|--batch  batch name for grouping results                -b SmokeTests

or

RunTest.pl -v|--version
RunTest.pl -h|--help
EOB
}
#------------------------------------------------------------------
