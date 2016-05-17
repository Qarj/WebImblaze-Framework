#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;
use File::Basename;

$VERSION = '1.01';

my $this_script_folder_full = dirname(__FILE__);
chdir $this_script_folder_full;

require Runner;

local $| = 1; # don't buffer output to STDOUT

my ($script_name, $script_path) = fileparse($0,'.pl');

my $config_wif_location = "../";
my $opt_batch = $script_name;
my ($opt_target, $config_environment) = Runner::read_wif_config($config_wif_location.'wif.config');

# add a random number to the batch name so this run will have a different name to a previous run
$opt_batch .= Runner::random(99_999);

# specify the location of the test files relative to this script
start('../../WebInject/selftest/addheader.xml');
start('../../WebInject/selftest/assertcount.xml');
start('../../WebInject/selftest/assertionskips.xml');
start('../../WebInject/selftest/autocontrolleronly.xml');
start('../../WebInject/selftest/commandonerror.xml');
start('../../WebInject/selftest/decodequotedprintable.xml');
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
start('../../WebInject/selftest/lastlooponly.xml');
start('../../WebInject/selftest/liveonly.xml');
start('../../WebInject/selftest/logastext.xml');
start('../../WebInject/selftest/logresponseasfile.xml');
start('../../WebInject/selftest/name_data.xml');
start('../../WebInject/selftest/parms.xml');
start('../../WebInject/selftest/parseresponse.xml');
start('../../WebInject/selftest/random.xml');
start('../../WebInject/selftest/repeat.xml');
start('../../WebInject/selftest/restartbrowser.xml');
start('../../WebInject/selftest/restartbrowseronfail.xml');
start('../../WebInject/selftest/retry.xml');
start('../../WebInject/selftest/retryfromstep.xml');
start('../../WebInject/selftest/retryresponsecode.xml');
start('../../WebInject/selftest/sanitycheck.xml');
start('../../WebInject/selftest/section.xml');
start('../../WebInject/selftest/substitutions.xml');
start('../../WebInject/selftest/testonly.xml');
start('../../WebInject/selftest/useragent.xml');
start('../../WebInject/selftest/var.xml');
start('../../WebInject/selftest/verifynegative.xml');
start('../../WebInject/selftest/verifypositive.xml');
start('../../WebInject/selftest/verifyresponsecode.xml');
start('../../WebInject/selftest/verifyresponsetime.xml');
start('../../WebInject/selftest/include.xml');



sub start {
    my ($_test) = @_;

    Runner::start_test($_test, $opt_target, $opt_batch, $config_environment, $config_wif_location);

    return;
}