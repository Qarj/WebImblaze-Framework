#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

package Runner;

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '1.01';

use Getopt::Long;
use Cwd;
use Config::Tiny;
use File::Spec;

sub start_test {
    my ($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location) = @_;

    my @_args = _build_wif_args($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location);

    # change dir to wif.pl location
    my $_orig_cwd = cwd;
    chdir $_config_wif_location;

    _start_windows_process('wif.pl '."@_args");

    chdir $_orig_cwd;

    return;
}

#------------------------------------------------------------------
sub call_test {
    my ($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location) = @_;

    my @_args = _build_wif_args($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location);

    # change dir to wif.pl location
    my $_orig_cwd = cwd;
    chdir $_config_wif_location;

    printf "%-69s ", $_test_file_full;
    print "...";

    my $_status = system('wif.pl '."@_args");
    if ($_status) {
        print " failed\n";
    } else {
        print " ok\n";
    }

    chdir $_orig_cwd;

    return $_status;
}

#------------------------------------------------------------------
sub _build_wif_args {
    my ($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location) = @_;

    my $_abs_test_file_full = File::Spec->rel2abs( $_test_file_full );

    my @_args;

    push @_args, $_abs_test_file_full;

    push @_args, '--target';
    push @_args, $_config_target;

    push @_args, '--batch';
    push @_args, $_config_batch;

    push @_args, '--env';
    push @_args, $_config_environment;

    push @_args, '--use-browsermob-proxy';
    push @_args, 'false';

    push @_args, '--no-update-config';

    push @_args, '--capture-stdout';

    return @_args;
}

#------------------------------------------------------------------
sub _start_windows_process {
    my ($_command) = @_;

    my $_cwd = cwd;
    my $_wmic = "wmic process call create 'cmd /c cd /D $_cwd & $_command'"; #

    my $_result;
    $_result = `$_wmic`;
    #print "_wmic:$_wmic\n";
    #print "$_result\n";

    my $_pid;
    if ( $_result =~ m/ProcessId = (\d+)/ ) {
        $_pid = $1;
    }

    return $_pid;
}

#------------------------------------------------------------------
sub random {
    my ($_max) = @_;

    my $_random = int rand $_max;
    $_random = sprintf '%05d', $_random; # add some leading zeros

    return '_'.$_random;
}

#------------------------------------------------------------------
sub read_config {
    my ($_config_file_full) = @_;

    my $_config = Config::Tiny->read( $_config_file_full );

    # main
    my $_config_batch = $_config->{main}->{batch};

    # path
    my $_config_wif_location = $_config->{path}->{wif_location};

    return ($_config_batch, $_config_wif_location);
}

#------------------------------------------------------------------
sub read_wif_config {
    my ($_config_file_full) = @_;

    my $_config = Config::Tiny->read( $_config_file_full );

    # main
    my $_config_target = $_config->{main}->{target};
    my $_config_environment = $_config->{main}->{environment};

    return ($_config_target, $_config_environment);
}

#------------------------------------------------------------------
sub get_options {
    my ($_opt_target, $_opt_batch, $_opt_environment) = @_;

    my ($_opt_version, $_opt_help);

    Getopt::Long::Configure('bundling');
    GetOptions(
        't|target=s'                => \$_opt_target,
        'b|batch=s'                 => \$_opt_batch,
        'e|env=s'                   => \$_opt_environment,
        'v|V|version'               => \$_opt_version,
        'h|help'                    => \$_opt_help,
        )
        or do {
            print_usage();
            exit;
        };

    if ($_opt_version) {
        print_version();
        exit;
    }

    if ($_opt_help) {
        print_version();
        print_usage();
        print "\nTarget         [$_opt_environment] $_opt_target\n";
        print "Batch          $_opt_batch\n";
        exit;
    }

    return $_opt_target, $_opt_batch, $_opt_environment;
}

sub print_version {
    print {*STDOUT} "\nRunner.pm version $VERSION\nFor more info: https://github.com/Qarj/WebInjectFramework\n";
    return;
}

sub print_usage {
    print <<'EOB'

Usage: <task_name>.pl tests\testfilename.xml <<options>>

-t|--target                 target "mini-environment"           --target skynet
-b|--batch                  batch name for grouping results     --batch Smoke

Smoke.pl -v|--version
Smoke.pl -h|--help
EOB
;
return;
}
#------------------------------------------------------------------

1;