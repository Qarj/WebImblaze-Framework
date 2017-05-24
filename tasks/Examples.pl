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
start('../../WebInject/examples/addcookie.xml');
start('../../WebInject/examples/addheader.xml');
start('../../WebInject/examples/assertcount.xml');
start('../../WebInject/examples/assertionskipsmessage.xml');
start('../../WebInject/examples/command.xml');
start('../../WebInject/examples/command20.xml');

start('../../WebInject/examples/commandonerror.xml');
start('../../WebInject/examples/corrupt.xml');
start('../../WebInject/examples/demo.xml');
start('../../WebInject/examples/errormessage.xml');
start('../../WebInject/examples/formatjson.xml');
start('../../WebInject/examples/formatxml.xml');
start('../../WebInject/examples/get.xml');
start('../../WebInject/examples/ignoreautoassertions.xml');
start('../../WebInject/examples/ignorehttpresponsecode.xml');
start('../../WebInject/examples/logastext.xml');
start('../../WebInject/examples/logresponseasfile.xml');
start('../../WebInject/examples/post.xml');
start('../../WebInject/examples/restartbrowser.xml');
start('../../WebInject/examples/retry.xml');
start('../../WebInject/examples/retryfromstep.xml');

start('../../WebInject/examples/retryresponsecode.xml');
start('../../WebInject/examples/sanitycheck.xml');
start('../../WebInject/examples/section.xml');
start('../../WebInject/examples/selenium.xml');
start('../../WebInject/examples/simple.xml');
start('../../WebInject/examples/sleep.xml');
start('../../WebInject/examples/verifynegative.xml');
start('../../WebInject/examples/verifypositive.xml');
start('../../WebInject/examples/verifyresponsecode.xml');

Runner::stop_runner();