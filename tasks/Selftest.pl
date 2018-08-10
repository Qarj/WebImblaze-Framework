#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use vars qw/ $VERSION /;

use File::Basename;
chdir dirname(__FILE__);
use lib '.';
require Runner;

$VERSION = '1.04';

## Usage:
##
## tasks\<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com

Runner::start_runner();

#SELFTEST ONLY:
my $update = system('..\..\WebInject-Selenium\plugins\update.pl');

# start the Selenium based tests first since they are slower
Runner::start('../../WebInject-Selenium/selftest/substeps/_click.test');
Runner::start('../../WebInject-Selenium/selftest/substeps/_keys_to_element.test');
Runner::start('../../WebInject-Selenium/selftest/substeps/_move_to.test');
Runner::start('../../WebInject-Selenium/selftest/substeps/_wait_visible.test');
Runner::start('../../WebInject-Selenium/selftest/selenium_core.test');

# specify the location of the test files relative to this script
Runner::start('../../WebInject/selftest/abort.test');
Runner::start('../../WebInject/selftest/addheader.test');
Runner::start('../../WebInject/selftest/assertcount.test');
Runner::start('../../WebInject/selftest/assertionskips.test');
Runner::start('../../WebInject/selftest/autocontrolleronly.test');
Runner::start('../../WebInject/selftest/autoretry.test');
Runner::start('../../WebInject/selftest/checkpoint.test');
Runner::start('../../WebInject/selftest/commandonfail.test');
Runner::start('../../WebInject/selftest/commandonerror.test');
Runner::start('../../WebInject/selftest/decodequotedprintable.test');
Runner::start('../../WebInject/selftest/donotrunon.test');
Runner::start('../../WebInject/selftest/errormessage.test');
Runner::start('../../WebInject/selftest/eval.test');
Runner::start('../../WebInject/selftest/firstlooponly.test');
Runner::start('../../WebInject/selftest/getallhrefs.test');
Runner::start('../../WebInject/selftest/getallsrcs.test');
Runner::start('../../WebInject/selftest/getbackgroundimages.test');
Runner::start('../../WebInject/selftest/httpauth.test');
Runner::start('../../WebInject/selftest/httppost.test');
Runner::start('../../WebInject/selftest/httppost_form-data.test');
Runner::start('../../WebInject/selftest/httppost_xml.test');
Runner::start('../../WebInject/selftest/ignoreautoassertions.test');
Runner::start('../../WebInject/selftest/ignorehttpresponsecode.test');
Runner::start('../../WebInject/selftest/ignoresmartassertions.test');
Runner::start('../../WebInject/selftest/include.test');
Runner::start('../../WebInject/selftest/lastlooponly.test');
Runner::start('../../WebInject/selftest/logastext.test');
Runner::start('../../WebInject/selftest/logresponseasfile.test');
Runner::start('../../WebInject/selftest/mask.test');
Runner::start('../../WebInject/selftest/nagios.test');
Runner::start('../../WebInject/selftest/name_data.test');
Runner::start('../../WebInject/selftest/parms.test');
Runner::start('../../WebInject/selftest/parseresponse.test');
Runner::start('../../WebInject/selftest/random.test');
Runner::start('../../WebInject/selftest/repeat.test');
Runner::start('../../WebInject/selftest/restartbrowser.test');
Runner::start('../../WebInject/selftest/restartbrowseronfail.test');
Runner::start('../../WebInject/selftest/result_files.test');
Runner::start('../../WebInject/selftest/retry.test');
Runner::start('../../WebInject/selftest/runif.test');
Runner::start('../../WebInject/selftest/runon.test');
Runner::start('../../WebInject/selftest/section.test');
Runner::start('../../WebInject/selftest/setcookie.test');
Runner::start('../../WebInject/selftest/sharedvar.test');
Runner::start('../../WebInject/selftest/specialcharacters.test');
Runner::start('../../WebInject/selftest/ssl.test');
Runner::start('../../WebInject/selftest/substitutions.test');
Runner::start('../../WebInject/selftest/unittest.test');
Runner::start('../../WebInject/selftest/useragent.test');
Runner::start('../../WebInject/selftest/var.test');
Runner::start('../../WebInject/selftest/verifynegative.test');
Runner::start('../../WebInject/selftest/verifypositive.test');
Runner::start('../../WebInject/selftest/verifyresponsecode.test');
Runner::start('../../WebInject/selftest/verifyresponsetime.test');

Runner::stop_runner();