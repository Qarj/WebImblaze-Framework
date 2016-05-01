#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;
use File::Basename;

$VERSION = '0.03';

my $this_script_folder_full = dirname(__FILE__);
chdir $this_script_folder_full;

require Runner;

local $| = 1; # don't buffer output to STDOUT

my ($script_name, $script_path) = fileparse($0,'.pl');

my $config_wif_location = "../";
my $config_batch = $script_name;
my ($config_target, $config_environment) = Runner::read_wif_config($config_wif_location.'wif.config');

# add a random number to the batch name so this run will have a different name to a previous run
$config_batch .= Runner::random(99_999);

# specify the location of the test files relative to this script
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command.xml');


sub start {
    my ($_test) = @_;

    Runner::start_test($_test, $config_target, $config_batch, $config_environment, $config_wif_location);

    return;
}

sub call {
    my ($_test) = @_;

    Runner::call_test($_test, $config_target, $config_batch, $config_environment, $config_wif_location);

    return;
}