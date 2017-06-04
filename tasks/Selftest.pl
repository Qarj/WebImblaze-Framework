#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use vars qw/ $VERSION /;

use File::Basename;
chdir dirname(__FILE__);
require Runner;

$VERSION = '1.04';

## Usage:
##
## tasks\<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com

Runner::start_runner();

#SELFTEST ONLY:
my $update = system('..\..\WebInject-Selenium\plugins\update.pl');

# start the Selenium based tests first since they are slower
Runner::start('../../WebInject-Selenium/selftest/substeps/helper_click.xml');
Runner::start('../../WebInject-Selenium/selftest/substeps/helper_keys_to_element.xml');
Runner::start('../../WebInject-Selenium/selftest/substeps/helper_move_to.xml');
Runner::start('../../WebInject-Selenium/selftest/substeps/helper_wait_visible.xml');
Runner::start('../../WebInject-Selenium/selftest/selenium_core.xml');

# specify the location of the test files relative to this script
Runner::start('../../WebInject/selftest/addheader.xml');
Runner::start('../../WebInject/selftest/assertcount.xml');
Runner::start('../../WebInject/selftest/assertionskips.xml');
Runner::start('../../WebInject/selftest/autocontrolleronly.xml');
Runner::start('../../WebInject/selftest/autoretry.xml');
Runner::start('../../WebInject/selftest/commandonerror.xml');
Runner::start('../../WebInject/selftest/decodequotedprintable.xml');
Runner::start('../../WebInject/selftest/donotrunon.xml');
Runner::start('../../WebInject/selftest/errormessage.xml');
Runner::start('../../WebInject/selftest/firstlooponly.xml');
Runner::start('../../WebInject/selftest/getbackgroundimages.xml');
Runner::start('../../WebInject/selftest/gethrefs.xml');
Runner::start('../../WebInject/selftest/getsrcs.xml');
Runner::start('../../WebInject/selftest/httpauth.xml');
Runner::start('../../WebInject/selftest/httppost.xml');
Runner::start('../../WebInject/selftest/httppost_form-data.xml');
Runner::start('../../WebInject/selftest/httppost_xml.xml');
Runner::start('../../WebInject/selftest/ignoreautoassertions.xml');
Runner::start('../../WebInject/selftest/ignorehttpresponsecode.xml');
Runner::start('../../WebInject/selftest/ignoresmartassertions.xml');
Runner::start('../../WebInject/selftest/include.xml');
Runner::start('../../WebInject/selftest/lastlooponly.xml');
Runner::start('../../WebInject/selftest/logastext.xml');
Runner::start('../../WebInject/selftest/logresponseasfile.xml');
Runner::start('../../WebInject/selftest/nagios.xml');
Runner::start('../../WebInject/selftest/name_data.xml');
Runner::start('../../WebInject/selftest/parms.xml');
Runner::start('../../WebInject/selftest/parseresponse.xml');
Runner::start('../../WebInject/selftest/random.xml');
Runner::start('../../WebInject/selftest/repeat.xml');
Runner::start('../../WebInject/selftest/restartbrowser.xml');
Runner::start('../../WebInject/selftest/restartbrowseronfail.xml');
Runner::start('../../WebInject/selftest/result_files.xml');
Runner::start('../../WebInject/selftest/retry.xml');
Runner::start('../../WebInject/selftest/retryfromstep.xml');
Runner::start('../../WebInject/selftest/runif.xml');
Runner::start('../../WebInject/selftest/runon.xml');
Runner::start('../../WebInject/selftest/sanitycheck.xml');
Runner::start('../../WebInject/selftest/section.xml');
Runner::start('../../WebInject/selftest/setcookie.xml');
Runner::start('../../WebInject/selftest/sharedvar.xml');
Runner::start('../../WebInject/selftest/specialcharacters.xml');
Runner::start('../../WebInject/selftest/substitutions.xml');
Runner::start('../../WebInject/selftest/useragent.xml');
Runner::start('../../WebInject/selftest/var.xml');
Runner::start('../../WebInject/selftest/verifynegative.xml');
Runner::start('../../WebInject/selftest/verifypositive.xml');
Runner::start('../../WebInject/selftest/verifyresponsecode.xml');
Runner::start('../../WebInject/selftest/verifyresponsetime.xml');
Runner::start('../../WebInject/selftest/xml-parse-fail.xml');

Runner::stop_runner();