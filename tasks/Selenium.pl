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

# specify the location of the test files relative to this script
Runner::start('../../WebInject-Selenium/examples/Caterer.test');
Runner::start('../../WebInject-Selenium/examples/Condobolin.test');
Runner::start('../../WebInject-Selenium/examples/food.gov.uk.test');
Runner::start('../../WebInject-Selenium/examples/govuk.test');
Runner::call('../../WebInject-Selenium/examples/graincorp.test');

Runner::start('../../WebInject-Selenium/examples/gumtree.test');
Runner::start('../../WebInject-Selenium/examples/Jobsite.test');
Runner::start('../../WebInject-Selenium/examples/NHSJobs.test');
Runner::start('../../WebInject-Selenium/examples/rightmove.test');
Runner::call('../../WebInject-Selenium/examples/searchimage.test');

Runner::start('../../WebInject-Selenium/examples/selenium.test');
Runner::start('../../WebInject-Selenium/examples/StepStone.test');
Runner::start('../../WebInject-Selenium/examples/test_jobs.test');
Runner::start('../../WebInject-Selenium/examples/trainline.test');
Runner::call('../../WebInject-Selenium/examples/tripadvisor.test');

Runner::start('../../WebInject-Selenium/examples/webinject-check.test');
Runner::start('../../WebInject-Selenium/selftest/substeps/_click.test');
Runner::start('../../WebInject-Selenium/selftest/substeps/_keys_to_element.test');
Runner::call('../../WebInject-Selenium/selftest/substeps/_move_to.test');

Runner::start('../../WebInject-Selenium/selftest/substeps/_wait_visible.test');
Runner::start('../../WebInject-Selenium/selftest/selenium_core.test');

Runner::stop_runner();