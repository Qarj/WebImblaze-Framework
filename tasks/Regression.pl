#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;
use File::Basename;

$VERSION = '1.02';

my $this_script_folder_full = dirname(__FILE__);
chdir $this_script_folder_full;

require Runner;
require Alerter;

local $| = 1; # don't buffer output to STDOUT

my ($script_name, $script_path) = fileparse($0,'.pl');

my $config_wif_location = "../";
my $opt_batch = $script_name;
my ($opt_target, $opt_environment) = Runner::read_wif_config($config_wif_location.'wif.config');

($opt_target, $opt_batch, $opt_environment) = Runner::get_options($opt_target, $opt_batch, $opt_environment);

# add a random number to the batch name so this run will have a different name to a previous run
$opt_batch .= Runner::random(99_999);

my $failed_test_files_count = 0;
my $passed_test_files_count = 0;
my @failed_test_files;

# specify the location of the test files relative to this script

#capturing return status only works with call for now, start is much more complicated
#for (1..2) {
#    start('../../WebInject/examples/command.xml');
#}
call('../../WebInject/examples/command.xml');
call('../../WebInject/examples/assertcount.xml');
call('../../WebInject/examples/command20.xml');

if ($failed_test_files_count) {
    my $_files = 'files';
    if ($failed_test_files_count == 1) { $_files = 'file'; }
    my $_message = "\n<!channel> There were errors in $script_name. $failed_test_files_count test $_files returned an error status:\n";
    foreach (@failed_test_files) {
        $_message .= '    ['.$_.']'."\n";
    }
    print $_message;
    #Alerter::slack_alert($_message, 'https://hooks.slack.com/services/X025XXX4X/X1XX2X38X/uXXXq9XXzX6XXhXXXnXx3XqX'); # Slack hook url
    exit 1;
} else {
    exit 0;
}

sub start {
    my ($_test) = @_;

    Runner::start_test($_test, $opt_target, $opt_batch, $opt_environment, $config_wif_location);

    return;
}

sub call {
    my ($_test) = @_;

    my $_status = Runner::call_test($_test, $opt_target, $opt_batch, $opt_environment, $config_wif_location);

    if ($_status) {
        $failed_test_files++;
    }

    return;
}