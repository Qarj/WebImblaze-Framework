#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

package Runner;

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.01';

use Cwd;
use Config::Tiny;
use File::Spec;

sub start_test {
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

    # wif.pl expects the current working directory to be where wif.pl is located
    my $_orig_cwd = cwd;
    chdir $_config_wif_location;

    _start_windows_process('wif.pl '."@_args");

    chdir $_orig_cwd;

    return;
}

#------------------------------------------------------------------
sub _start_windows_process {
    my ($_command) = @_;

    my $_cwd = cwd;
    my $_wmic = "wmic process call create 'cmd /c cd $_cwd & $_command'"; #

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
    my $_config_target = $_config->{main}->{target};
    my $_config_batch = $_config->{main}->{batch};
    my $_config_environment = $_config->{main}->{environment};

    # path
    my $_config_wif_location = $_config->{path}->{wif_location};

    return ($_config_target, $_config_batch, $_config_environment, $_config_wif_location);
}

1;