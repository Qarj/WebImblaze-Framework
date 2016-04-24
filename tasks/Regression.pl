#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.01';

use Cwd;
use Config::Tiny;
use File::Spec;

local $| = 1; # don't buffer output to STDOUT

my ($config_target, $config_batch, $config_environment, $config_wif_location);

read_config();

# add a random number to the batch name so this run will have a different name to a previous run
my $_random = int rand 99_999;
$_random = sprintf '%05d', $_random; # add some leading zeros
$config_batch .= q{_}.$_random;

# specify the location of the test files relative to this script
start_test('../../WebInject/examples/command.xml');
start_test('../../WebInject/examples/command.xml');

sub start_test {
    my ($_test_file_full) = @_;

    my $_abs_test_file_full = File::Spec->rel2abs( $_test_file_full );

    my @_args;

    push @_args, $_abs_test_file_full;

    push @_args, '--target';
    push @_args, $config_target;

    push @_args, '--batch';
    push @_args, $config_batch;

    push @_args, '--env';
    push @_args, $config_environment;

    push @_args, '--use-browsermob-proxy';
    push @_args, 'false';

    push @_args, '--no-update-config';

    # wif.pl expects the current working directory to be where wif.pl is located
    my $_orig_cwd = cwd;
    chdir $config_wif_location;

    _start_windows_process('wif.pl '."@_args");

    chdir $_orig_cwd;

    return;
}

#------------------------------------------------------------------
sub _start_windows_process {
    my ($_command) = @_;

    my $_cwd = cwd;
    my $_wmic = "wmic process call create 'cmd /c cd $_cwd & $_command'"; #

    my $_result = `$_wmic`;
    #print "_wmic:$_wmic\n";
    #print "$_result\n";

    my $_pid;
    if ( $_result =~ m/ProcessId = (\d+)/ ) {
        $_pid = $1;
    }

    return $_pid;
}

#------------------------------------------------------------------
sub read_config {
    my $_config = Config::Tiny->read( 'Regression.config' );

    # main
    $config_target = $_config->{main}->{target};
    $config_batch = $_config->{main}->{batch};
    $config_environment = $_config->{main}->{environment};

    # path
    $config_wif_location = $_config->{path}->{wif_location};

    return;
}