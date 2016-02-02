#!/usr/bin/perl
use strict;
use warnings;

#    WebInjectFramework is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    WebInjectFramework is distributed in the hope that it will be useful,
#    but without any warranty; without even the implied warranty of
#    merchantability or fitness for a particular purpose.  See the
#    GNU General Public License for more details.


my $version="0.01";

my ( $opt_version, $opt_target, $opt_batch, $opt_help );

use Getopt::Long;

$| = 1; #don't buffer output to STDOUT

engine();

#------------------------------------------------------------------
sub engine {
      
    getoptions();  #get command line options
}

#------------------------------------------------------------------
sub getoptions {  #shell options
        
    Getopt::Long::Configure('bundling');
    GetOptions(
        'v|V|version'   => \$opt_version,
        't|target=s'    => \$opt_target,
        'b|batch=s'    => \$opt_batch,
        'h|help'   => \$opt_help,
        ) 
        or do {
            print_usage();
            exit();
        };
    if ($opt_version) {
        print_version();
        exit();
    }
    if ($opt_help) {
        print_version();
        print_usage();
        exit();
    }
}

sub print_version {
    print "\nWebInjectFramework version $version\nFor more info: https://github.com/Qarj/WebInjectFramework\n\n";
}

sub print_usage {
print <<EOB
Usage: RunTest.pl <<options>>

-t|--target target environment handle                      -t skynet
-o|--batch  batch name for grouping results                -b SmokeTests

or

RunTest.pl -v|--version
RunTest.pl -h|--help
EOB
    }
#------------------------------------------------------------------
