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
Runner::start('../../WebInject/examples/abort.xml');
Runner::start('../../WebInject/examples/addcookie.xml');
Runner::start('../../WebInject/examples/addheader.xml');
Runner::start('../../WebInject/examples/assertcount.xml');
Runner::start('../../WebInject/examples/assertionskipsmessage.xml');
Runner::start('../../WebInject/examples/command.xml');
Runner::start('../../WebInject/examples/command20.xml');

Runner::start('../../WebInject/examples/commandonerror.xml');
Runner::start('../../WebInject/examples/corrupt.xml');
Runner::start('../../WebInject/examples/demo.xml');
Runner::start('../../WebInject/examples/errormessage.xml');
Runner::start('../../WebInject/examples/formatjson.xml');
Runner::start('../../WebInject/examples/formatxml.xml');
Runner::start('../../WebInject/examples/get.xml');
Runner::start('../../WebInject/examples/ignoreautoassertions.xml');
Runner::start('../../WebInject/examples/ignorehttpresponsecode.xml');
Runner::start('../../WebInject/examples/logastext.xml');
Runner::start('../../WebInject/examples/logresponseasfile.xml');
Runner::start('../../WebInject/examples/post.xml');
Runner::start('../../WebInject/examples/restartbrowser.xml');
Runner::start('../../WebInject/examples/retry.xml');
Runner::start('../../WebInject/examples/retryfromstep.xml');

Runner::start('../../WebInject/examples/retryresponsecode.xml');
Runner::start('../../WebInject/examples/section.xml');
Runner::start('../../WebInject/examples/selenium.xml');
Runner::start('../../WebInject/examples/simple.xml');
Runner::start('../../WebInject/examples/sleep.xml');
Runner::start('../../WebInject/examples/verifynegative.xml');
Runner::start('../../WebInject/examples/verifypositive.xml');
Runner::start('../../WebInject/examples/verifyresponsecode.xml');

Runner::stop_runner();