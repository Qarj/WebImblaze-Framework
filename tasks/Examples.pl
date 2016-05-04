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
my $opt_batch = $script_name;
my ($opt_target, $config_environment) = Runner::read_wif_config($config_wif_location.'wif.config');

# add a random number to the batch name so this run will have a different name to a previous run
$opt_batch .= Runner::random(99_999);

# specify the location of the test files relative to this script
start('../../WebInject/examples/addcookie.xml');
start('../../WebInject/examples/addheader.xml');
start('../../WebInject/examples/assertcount.xml');
start('../../WebInject/examples/assertionskipsmessage.xml');
start('../../WebInject/examples/checknegative.xml');
start('../../WebInject/examples/checkpositive.xml');
start('../../WebInject/examples/checkresponsecode.xml');
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



sub start {
    my ($_test) = @_;

    Runner::start_test($_test, $opt_target, $opt_batch, $config_environment, $config_wif_location);

    return;
}