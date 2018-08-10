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
## perl tasks\<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com

Runner::start_runner();

# specify the location of the test files relative to this script
Runner::start('../../WebInject/examples/abort.test');
Runner::start('../../WebInject/examples/addcookie.test');
Runner::start('../../WebInject/examples/addheader.test');
Runner::start('../../WebInject/examples/assertcount.test');
Runner::start('../../WebInject/examples/command.test');
Runner::start('../../WebInject/examples/command20.test');

Runner::start('../../WebInject/examples/commandonerror.test');
Runner::start('../../WebInject/examples/errormessage.test');
Runner::start('../../WebInject/examples/formatjson.test');
Runner::start('../../WebInject/examples/formatxml.test');
Runner::start('../../WebInject/examples/get.test');
Runner::start('../../WebInject/examples/ignoreautoassertions.test');
Runner::start('../../WebInject/examples/ignorehttpresponsecode.test');
Runner::start('../../WebInject/examples/logastext.test');
Runner::start('../../WebInject/examples/logresponseasfile.test');
Runner::start('../../WebInject/examples/post.test');
Runner::start('../../WebInject/examples/restartbrowser.test');
Runner::start('../../WebInject/examples/retry.test');
Runner::start('../../WebInject/examples/retryfromstep.test');

Runner::start('../../WebInject/examples/retryresponsecode.test');
Runner::start('../../WebInject/examples/section.test');
Runner::start('../../WebInject/examples/selenium.test');
Runner::start('../../WebInject/examples/simple.test');
Runner::start('../../WebInject/examples/sleep.test');
Runner::start('../../WebInject/examples/verifynegative.test');
Runner::start('../../WebInject/examples/verifypositive.test');
Runner::start('../../WebInject/examples/verifyresponsecode.test');

Runner::stop_runner();