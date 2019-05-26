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

$VERSION = '1.6.1';

## Usage:
##
## perl tasks/<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com --slack-alert http://hook.url

Runner::start_runner();

#SELFTEST ONLY:
my $update = system('..\..\WebImblaze-Selenium\plugins\update.pl');

# specify the location of the test files relative to this script
Runner::start('../../WebImblaze-Selenium/examples/Caterer.test');
Runner::start('../../WebImblaze-Selenium/examples/Condobolin.test');
Runner::start('../../WebImblaze-Selenium/examples/food.gov.uk.test');
Runner::start('../../WebImblaze-Selenium/examples/govuk.test');
Runner::call('../../WebImblaze-Selenium/examples/graincorp.test');

Runner::start('../../WebImblaze-Selenium/examples/Jobsite.test');
Runner::start('../../WebImblaze-Selenium/examples/NHSJobs.test');
Runner::start('../../WebImblaze-Selenium/examples/rightmove.test');
Runner::call('../../WebImblaze-Selenium/examples/searchimage.test');

Runner::start('../../WebImblaze-Selenium/examples/selenium.test');
Runner::start('../../WebImblaze-Selenium/examples/StepStone.test');
Runner::start('../../WebImblaze-Selenium/examples/test_jobs.test');
Runner::call('../../WebImblaze-Selenium/examples/trainline.test');

Runner::start('../../WebImblaze-Selenium/selftest/substeps/_click.test');
Runner::start('../../WebImblaze-Selenium/selftest/substeps/_keys_to_element.test');
Runner::call('../../WebImblaze-Selenium/selftest/substeps/_move_to.test');

Runner::start('../../WebImblaze-Selenium/selftest/substeps/_wait_visible.test');
Runner::start('../../WebImblaze-Selenium/selftest/selenium_core.test');

Runner::stop_runner();