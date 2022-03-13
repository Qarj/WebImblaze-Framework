#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use vars qw/ $VERSION /;

use File::Basename;
chdir dirname(__FILE__);
use lib q{.};
require Runner;

$VERSION = '1.6.3';

## Usage:
##
## perl tasks/<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com --slack-alert http://hook.url

Runner::start_runner();

#SELFTEST ONLY:
my $update = system( Runner::slash_me('..\..\WebImblaze-Selenium\plugins\update.pl') );

# start the Selenium based tests first since they are slower
Runner::start('../../WebImblaze-Selenium/selftest/useragent.test');
Runner::start('../../WebImblaze-Selenium/selftest/substeps/_click.test');
Runner::start('../../WebImblaze-Selenium/selftest/substeps/_keys_to_element.test');
Runner::start('../../WebImblaze-Selenium/selftest/substeps/_move_to.test');
Runner::start('../../WebImblaze-Selenium/selftest/substeps/_wait_visible.test');
Runner::start('../../WebImblaze-Selenium/selftest/selenium_core.test');

# specify the location of the test files relative to this script
Runner::start('../../WebImblaze/selftest/abort.test');
Runner::start('../../WebImblaze/selftest/addheader.test');
Runner::start('../../WebImblaze/selftest/assertcount.test');
Runner::start('../../WebImblaze/selftest/assertionskips.test');
Runner::start('../../WebImblaze/selftest/autocontrolleronly.test');
Runner::start('../../WebImblaze/selftest/autoretry.test');
Runner::start('../../WebImblaze/selftest/checkpoint.test');
Runner::start('../../WebImblaze/selftest/commandonerror.test');
Runner::start('../../WebImblaze/selftest/commandonfail.test');
Runner::start('../../WebImblaze/selftest/decodequotedprintable.test');
Runner::start('../../WebImblaze/selftest/donotrunon.test');
Runner::start('../../WebImblaze/selftest/errormessage.test');
Runner::start('../../WebImblaze/selftest/eval.test');
Runner::start('../../WebImblaze/selftest/firstlooponly.test');
Runner::start('../../WebImblaze/selftest/getallhrefs.test');
Runner::start('../../WebImblaze/selftest/getallsrcs.test');
Runner::start('../../WebImblaze/selftest/getbackgroundimages.test');
Runner::start('../../WebImblaze/selftest/gotostep.test');
Runner::start('../../WebImblaze/selftest/gzip.test');
Runner::start('../../WebImblaze/selftest/httpauth.test');
Runner::start('../../WebImblaze/selftest/httppost.test');
Runner::start('../../WebImblaze/selftest/httppost_form-data.test');
Runner::start('../../WebImblaze/selftest/httppost_xml.test');
Runner::start('../../WebImblaze/selftest/httppost_xml-substitutions.test');
Runner::start('../../WebImblaze/selftest/ignoreautoassertions.test');
Runner::start('../../WebImblaze/selftest/ignorehttpresponsecode.test');
Runner::start('../../WebImblaze/selftest/ignoresmartassertions.test');
Runner::start('../../WebImblaze/selftest/include.test');
Runner::start('../../WebImblaze/selftest/lastlooponly.test');
Runner::start('../../WebImblaze/selftest/logastext.test');
Runner::start('../../WebImblaze/selftest/logresponseasfile.test');
Runner::start('../../WebImblaze/selftest/mask.test');
Runner::start('../../WebImblaze/selftest/nagios.test');
Runner::start('../../WebImblaze/selftest/name_data.test');
Runner::start('../../WebImblaze/selftest/parseresponse.test');
Runner::start('../../WebImblaze/selftest/random.test');
Runner::start('../../WebImblaze/selftest/repeat.test');
Runner::start('../../WebImblaze/selftest/restartbrowser.test');
Runner::start('../../WebImblaze/selftest/restartbrowseronfail.test');
Runner::start('../../WebImblaze/selftest/result_files.test');
Runner::start('../../WebImblaze/selftest/retry.test');
Runner::start('../../WebImblaze/selftest/runif.test');
Runner::start('../../WebImblaze/selftest/runon.test');
Runner::start('../../WebImblaze/selftest/section.test');
Runner::start('../../WebImblaze/selftest/setcookie.test');
Runner::start('../../WebImblaze/selftest/sharedvar.test');
Runner::start('../../WebImblaze/selftest/specialcharacters.test');
Runner::start('../../WebImblaze/selftest/ssl.test');
Runner::start('../../WebImblaze/selftest/substitutions.test');
Runner::start('../../WebImblaze/selftest/unittest.test');
Runner::start('../../WebImblaze/selftest/useragent.test');
Runner::start('../../WebImblaze/selftest/UTF-8.test');
Runner::start('../../WebImblaze/selftest/var.test');
Runner::start('../../WebImblaze/selftest/verifynegative.test');
Runner::start('../../WebImblaze/selftest/verifypositive.test');
Runner::start('../../WebImblaze/selftest/verifyresponsecode.test');
Runner::start('../../WebImblaze/selftest/verifyresponsetime.test');

Runner::stop_runner();
