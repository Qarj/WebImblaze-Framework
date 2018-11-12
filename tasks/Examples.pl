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

$VERSION = '1.05';

## Usage:
##
## perl tasks/<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com

Runner::start_runner();

# specify the location of the test files relative to this script

# examples root
Runner::start('../../WebImblaze/examples/api.test');
Runner::start('../../WebImblaze/examples/data_driven.test');
Runner::start('../../WebImblaze/examples/demo.test');
Runner::start('../../WebImblaze/examples/get.test');
Runner::start('../../WebImblaze/examples/multipart_post.test');
Runner::start('../../WebImblaze/examples/post.test');
Runner::start('../../WebImblaze/examples/quotes.test');
Runner::start('../../WebImblaze/examples/retry.test');
Runner::start('../../WebImblaze/examples/verifynegative.test');
Runner::start('../../WebImblaze/examples/verifypositive.test');

# examples/advanced
Runner::start('../../WebImblaze/examples/abort.test');
Runner::start('../../WebImblaze/examples/addheader.test');
Runner::start('../../WebImblaze/examples/assertcount.test');
Runner::start('../../WebImblaze/examples/commandonerror.test');
Runner::start('../../WebImblaze/examples/errormessage.test');
Runner::start('../../WebImblaze/examples/formatjson.test');
Runner::start('../../WebImblaze/examples/formatxml.test');
Runner::start('../../WebImblaze/examples/hello.test');
Runner::start('../../WebImblaze/examples/ignoreautoassertions.test');
Runner::start('../../WebImblaze/examples/ignorehttpresponsecode.test');
Runner::start('../../WebImblaze/examples/include.test');
Runner::start('../../WebImblaze/examples/logastext.test');
Runner::start('../../WebImblaze/examples/logresponseasfile.test');
Runner::start('../../WebImblaze/examples/restartbrowser.test');
Runner::start('../../WebImblaze/examples/restartbrowseronfail.test');
Runner::start('../../WebImblaze/examples/section.test');
Runner::start('../../WebImblaze/examples/setcookie.test');
Runner::start('../../WebImblaze/examples/shell.test');
Runner::start('../../WebImblaze/examples/sleep.test');
Runner::start('../../WebImblaze/examples/verifyresponsecode.test');

# examples/misc
Runner::start('../../WebImblaze/examples/fail.test');
Runner::start('../../WebImblaze/examples/myaccount.test');
Runner::start('../../WebImblaze/examples/selenium.test');
Runner::start('../../WebImblaze/examples/simple.test');
Runner::start('../../WebImblaze/examples/simple_post.test');
Runner::start('../../WebImblaze/examples/slow.test');
Runner::start('../../WebImblaze/examples/test.test');

Runner::stop_runner();