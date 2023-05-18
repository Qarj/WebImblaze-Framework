#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$
# -*- coding: utf-8 -*-
# perl

use v5.16;
use strict;
use warnings;
use vars qw/ $VERSION /;

use File::Basename;
chdir dirname(__FILE__);
use lib q{.};
require Runner;

$VERSION = '1.0.0';

## Usage:
##
## perl tasks/<task_filename>.pl --env PAT --target bcs --batch Core_Regression --check-alive http://www.example.com --slack-alert http://hook.url

Runner::start_runner();

# specify the location of the test files relative to this script
Runner::start('../../WebImblaze/selftest/assertcount.test');
Runner::start('../../WebImblaze/selftest/checkpoint.test');
Runner::start('../../WebImblaze/selftest/gotostep.test');
Runner::start('../../WebImblaze/selftest/include.test');
Runner::call('../../WebImblaze/selftest/random.test');

Runner::stop_runner();
