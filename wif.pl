#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.01';

#    WebInjectFramework is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    WebInjectFramework is distributed in the hope that it will be useful,
#    but without any warranty; without even the implied warranty of
#    merchantability or fitness for a particular purpose.  See the
#    GNU General Public License for more details.

#    Example: 
#              wif.pl ../WebInject/examples/simple.xml --target myenv

use Getopt::Long;
use File::Basename;

local $| = 1; # don't buffer output to STDOUT

my ( $opt_version, $opt_target, $opt_batch, $opt_environment, $opt_help, $testfile, $testfile_name, $testfile_path );
get_options();  # get command line options

# generate a random folder for the temporary files
my $temp_folder = create_temp_folder();

# find out where to publish the results
my $web_server = get_web_server_location();

# tear down
remove_temp_folder($temp_folder);

#------------------------------------------------------------------
sub get_web_server_location {

    my $cmd = 'subs\get_web_server_location.pl';
    my $server_location = `$cmd`;
    #print {*STDOUT} "$server_location [$server_location]\n";

    return $server_location;
}
#------------------------------------------------------------------
sub create_temp_folder {
    my $random = int rand 99_999;
    $random = sprintf '%05d', $random; # add some leading zeros

    my $random_folder = $opt_target . '_' . $testfile_name . '_' . $random;
    mkdir 'temp/' . $random_folder or die "Could not create temporary folder temp/$random_folder\n";

    return $random_folder;
}

#------------------------------------------------------------------
sub remove_temp_folder {
    my ($random_folder) = @_;

    if (-e "'temp/$random_folder/*'") {
        unlink glob "'temp/$random_folder/*'" or die "Could not delete temporary files in folder temp/$random_folder\n";
    }

    rmdir 'temp/' . $random_folder or die "Could not remove temporary folder temp/$random_folder\n";

    return;
}

#------------------------------------------------------------------
sub get_options {  #shell options

    $opt_environment = 'DEV'; # default the environment name
    $opt_batch = 'Default_Batch';

    Getopt::Long::Configure('bundling');
    GetOptions(
        't|target=s'  => \$opt_target,
        'b|batch=s'   => \$opt_batch,
        'e|env=s'   => \$opt_environment,
        'v|V|version' => \$opt_version,
        'h|help'      => \$opt_help,
        )
        or do {
            print_usage();
            exit;
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

    # read the testfile name, and ensure it exists
    if (($#ARGV + 1) < 1) {
        print "\nERROR: No test file name given\n";
        print_usage();
        exit;
    } else {
        $testfile = $ARGV[0];
    }
    ($testfile_name, $testfile_path) = fileparse($testfile,'.xml');

    if (not -e $testfile) {
        die "\n\nERROR: no such test file found $testfile\n";
    }

    if (not defined $opt_target) {
        print "\n\nERROR: Target sub environment name must be specified\n";
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

Usage: wif.pl tests\testfilename.xml <<options>>

-t|--target target environment handle             --target skynet
-b|--batch  batch name for grouping results       --batch SmokeTests

or

wif.pl -v|--version
wif.pl -h|--help
EOB
;
return;
}
#------------------------------------------------------------------
