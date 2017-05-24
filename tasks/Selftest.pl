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

Runner::stop_runner();