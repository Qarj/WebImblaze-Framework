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
Runner::start('../../WebInject-Selenium/examples/Caterer.xml');
Runner::start('../../WebInject-Selenium/examples/Condobolin.xml');
Runner::start('../../WebInject-Selenium/examples/food.gov.uk.xml');
Runner::start('../../WebInject-Selenium/examples/govuk.xml');
Runner::start('../../WebInject-Selenium/examples/graincorp.xml');
Runner::start('../../WebInject-Selenium/examples/gumtree.xml');
Runner::start('../../WebInject-Selenium/examples/Jobsite.xml');
Runner::start('../../WebInject-Selenium/examples/NHSJobs.xml');
Runner::start('../../WebInject-Selenium/examples/rightmove.xml');
Runner::start('../../WebInject-Selenium/examples/searchimage.xml');
Runner::start('../../WebInject-Selenium/examples/selenium.xml');
Runner::start('../../WebInject-Selenium/examples/StepStone.xml');
Runner::start('../../WebInject-Selenium/examples/test_jobs.xml');
Runner::start('../../WebInject-Selenium/examples/trainline.xml');
Runner::start('../../WebInject-Selenium/examples/tripadvisor.xml');
Runner::start('../../WebInject-Selenium/examples/webinject-check.xml');

# start the Selenium based tests first since they are slower
Runner::start('../../WebInject-Selenium/selftest/substeps/_click.xml');
Runner::start('../../WebInject-Selenium/selftest/substeps/_keys_to_element.xml');
Runner::start('../../WebInject-Selenium/selftest/substeps/_move_to.xml');
Runner::start('../../WebInject-Selenium/selftest/substeps/_wait_visible.xml');
Runner::start('../../WebInject-Selenium/selftest/selenium_core.xml');

Runner::stop_runner();