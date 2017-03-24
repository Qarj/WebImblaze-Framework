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


#SELFTEST ONLY:
my $update = system('..\..\WebInject-Selenium\plugins\update.pl');

# start the Selenium based tests first since they are slower
start('../../WebInject-Selenium/selftest/substeps/helper_click.xml');
start('../../WebInject-Selenium/selftest/substeps/helper_keys_to_element.xml');
start('../../WebInject-Selenium/selftest/substeps/helper_move_to.xml');
start('../../WebInject-Selenium/selftest/substeps/helper_wait_visible.xml');
start('../../WebInject-Selenium/selftest/selenium_core.xml');

# specify the location of the test files relative to this script
start('../../WebInject/selftest/addheader.xml');
start('../../WebInject/selftest/assertcount.xml');
start('../../WebInject/selftest/assertionskips.xml');
start('../../WebInject/selftest/autocontrolleronly.xml');
start('../../WebInject/selftest/autoretry.xml');
start('../../WebInject/selftest/commandonerror.xml');
start('../../WebInject/selftest/decodequotedprintable.xml');
start('../../WebInject/selftest/donotrunon.xml');
start('../../WebInject/selftest/errormessage.xml');
start('../../WebInject/selftest/firstlooponly.xml');
start('../../WebInject/selftest/getbackgroundimages.xml');
start('../../WebInject/selftest/gethrefs.xml');
start('../../WebInject/selftest/getsrcs.xml');
start('../../WebInject/selftest/httpauth.xml');
start('../../WebInject/selftest/httppost.xml');
start('../../WebInject/selftest/httppost_form-data.xml');
start('../../WebInject/selftest/httppost_xml.xml');
start('../../WebInject/selftest/ignoreautoassertions.xml');
start('../../WebInject/selftest/ignorehttpresponsecode.xml');
start('../../WebInject/selftest/ignoresmartassertions.xml');
start('../../WebInject/selftest/include.xml');
start('../../WebInject/selftest/lastlooponly.xml');
start('../../WebInject/selftest/logastext.xml');
start('../../WebInject/selftest/logresponseasfile.xml');
start('../../WebInject/selftest/nagios.xml');
start('../../WebInject/selftest/name_data.xml');
start('../../WebInject/selftest/parms.xml');
start('../../WebInject/selftest/parseresponse.xml');
start('../../WebInject/selftest/random.xml');
start('../../WebInject/selftest/repeat.xml');
start('../../WebInject/selftest/restartbrowser.xml');
start('../../WebInject/selftest/restartbrowseronfail.xml');
start('../../WebInject/selftest/result_files.xml');
start('../../WebInject/selftest/retry.xml');
start('../../WebInject/selftest/retryfromstep.xml');
start('../../WebInject/selftest/runon.xml');
start('../../WebInject/selftest/sanitycheck.xml');
start('../../WebInject/selftest/section.xml');
start('../../WebInject/selftest/specialcharacters.xml');
start('../../WebInject/selftest/substitutions.xml');
start('../../WebInject/selftest/useragent.xml');
start('../../WebInject/selftest/var.xml');
start('../../WebInject/selftest/verifynegative.xml');
start('../../WebInject/selftest/verifypositive.xml');
start('../../WebInject/selftest/verifyresponsecode.xml');
start('../../WebInject/selftest/verifyresponsetime.xml');
start('../../WebInject/selftest/xml-parse-fail.xml');

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