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

# specify the location of the test files relative to this script
Runner::start('../../WebInject/examples/myaccount.xml');
Runner::start('../../WebInject/examples/myaccount.xml');
Runner::start('../../WebInject/examples/myaccount.xml');
Runner::start('../../WebInject/examples/myaccount.xml');
Runner::start('../../WebInject/examples/myaccount.xml');

Runner::stop_runner();