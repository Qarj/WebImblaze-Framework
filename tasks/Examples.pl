#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;
use File::Basename;

$VERSION = '1.02';

## Usage:
##
## tasks\Selftest.pl --env DEV --target webinject_examples --batch WebInject_SelfTest

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
$opt_target = lc $opt_target;
$opt_environment = uc $opt_environment;

# add a random number to the batch name so this run will have a different name to a previous run
$opt_batch .= Runner::random(99_999);

#capturing return status only works with call for now, start is much more complicated
my $failed_test_files_count = 0;
my $passed_test_files_count = 0;
my @failed_test_files;

# specify the location of the test files relative to this script
start('../../WebInject/examples/addcookie.xml');
start('../../WebInject/examples/addheader.xml');
start('../../WebInject/examples/assertcount.xml');
start('../../WebInject/examples/assertionskipsmessage.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command20.xml');

start('../../WebInject/examples/commandonerror.xml');
start('../../WebInject/examples/corrupt.xml');
start('../../WebInject/examples/demo.xml');
start('../../WebInject/examples/errormessage.xml');
start('../../WebInject/examples/formatjson.xml');
start('../../WebInject/examples/formatxml.xml');
start('../../WebInject/examples/get.xml');
start('../../WebInject/examples/ignoreautoassertions.xml');
start('../../WebInject/examples/ignorehttpresponsecode.xml');
start('../../WebInject/examples/logastext.xml');
start('../../WebInject/examples/logresponseasfile.xml');
start('../../WebInject/examples/post.xml');
start('../../WebInject/examples/restartbrowser.xml');
start('../../WebInject/examples/retry.xml');
start('../../WebInject/examples/retryfromstep.xml');

start('../../WebInject/examples/retryresponsecode.xml');
start('../../WebInject/examples/sanitycheck.xml');
start('../../WebInject/examples/section.xml');
start('../../WebInject/examples/selenium.xml');
start('../../WebInject/examples/simple.xml');
start('../../WebInject/examples/sleep.xml');
start('../../WebInject/examples/verifynegative.xml');
start('../../WebInject/examples/verifypositive.xml');
start('../../WebInject/examples/verifyresponsecode.xml');

if ($failed_test_files_count) {
    my $_files = 'files';
    if ($failed_test_files_count == 1) { $_files = 'file'; }
    my $_message = "There were errors in $script_name. $failed_test_files_count test $_files returned an error status:\n";
    foreach (@failed_test_files) {
        $_message .= '    ['.$_.']'."\n";
    }
    print "\n".$_message;
    #Alerter::slack_alert('<!channel> '.$_message, 'https://hooks.slack.com/services/AAA/BBB/aaabbb');
    exit 1;
} else {
    exit 0;
}

## Start httppost.xml in a new process and carry on execution
##
## repeat('../../WebInject/Selftest/httppost.xml', 5);
sub start {
    my ($_test) = @_;

    Runner::start_test($_test, $opt_target, $opt_batch, $opt_environment, $config_wif_location);

    return;
}

## Run httppost.xml in process and wait until it is finished before return
##
## repeat('../../WebInject/Selftest/httppost.xml', 5);
sub call {
    my ($_test) = @_;

    my $_status = Runner::call_test($_test, $opt_target, $opt_batch, $opt_environment, $config_wif_location);

    my ($_test_name, undef) = fileparse($_test,'.xml');

    if ($_status) {
        $failed_test_files_count++;
        push @failed_test_files, $_test_name;
    } else {
        $passed_test_files_count++;
    }

    return;
}

## Repeat httppost.xml test 5 times
##
## repeat('../../WebInject/Selftest/httppost.xml', 5);
sub repeat {
    my ($_test, $_repeats) = @_;

    for my $_idx (1..$_repeats) {
        call($_test);
    }
}