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

$VERSION = '1.13.2';

#    WebImblaze-Framework is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    WebImblaze-Framework is distributed in the hope that it will be useful,
#    but without any warranty; without even the implied warranty of
#    merchantability or fitness for a particular purpose.  See the
#    GNU General Public License for more details.

#    Example: 
#              perl wif.pl ../WebImblaze/examples/demo.xml --target skynet --batch demonstration
#              perl wif.pl ../WebImblaze/examples/command.xml --target skynet --batch allgood
#              perl wif.pl ../WebImblaze/examples/abort.xml --target skynet --batch veryverybad
#              perl wif.pl ../WebImblaze/examples/errormessage.xml --target skynet --batch notgood
#              perl wif.pl ../WebImblaze/examples/corrupt.xml --target skynet --batch worstpossible
#              perl wif.pl ../WebImblaze/examples/sleep.xml --target skynet --batch tired
#              perl wif.pl ../WebImblaze/examples/selenium.xml --target skynet --batch gui

use Getopt::Long;
use File::Basename;
use File::Spec;
use File::Slurp;
use File::Copy qw(copy), qw(move);
use File::Path qw(make_path remove_tree);
use Cwd;
use Time::HiRes 'time','sleep';
use Config::Tiny;
use XML::Simple;
use XML::Twig;
require Data::Dumper;

my $start_folder_full = getcwd;
my (undef, $this_script_folder_full, undef) = fileparse(File::Spec->rel2abs( __FILE__ ));
chdir $this_script_folder_full;
use lib q{.}; # current folder is not @INC from Perl 5.26
require lib::BatchSummary;

local $| = 1; # don't buffer output to STDOUT

my $is_windows = $^O eq 'MSWin32' ? 1 : 0;

my $DEFAULT_OUTPUT_LOCATION = './temp/';
my $DEFAULT_WEBIMBLAZE_LOCATION = '../WebImblaze';
my $LEGACY_DEFAULT_DRIVER = 'chrome';
my $DEFAULT_DRIVER = 'chromedriver';

# start globally read/write variables declaration - only variables declared here will be read/written directly from subs
my ( $opt_version, $opt_target, $opt_batch, $opt_environment, $opt_selenium_host, $opt_selenium_port, $opt_headless, $opt_no_retry, $opt_help, $opt_keep, $opt_keep_session, $opt_resume_session, $opt_capture_stdout, $opt_no_update_config, $opt_show_batch_url);
my ( $testfile_full, $testfile_name, $testfile_path, $testfile_parent_folder_name );
my ( $config_is_automation_controller );
my ( $web_server_location_full, $web_server_address, $selenium_location_full, $driver, $chromedriver_location_full, $webimblaze_location, $output_location );
my ( $temp_folder_name );
my $config = Config::Tiny->new;
my $target_config = Config::Tiny->new;
my $global_config = Config::Tiny->new;
my $environment_config = Config::Tiny->new;
my ( $std_fh );
# end globally read/write variables

# start globally read variables  - will only be written to from the main script
my ( $yyyy, $mm, $dd, $hour, $minute, $second, $seconds ) = get_date(0); ## no critic(NamingConventions::ProhibitAmbiguousNames)
# get date for yesterday - needs to be calculated at script start, not at script end where it is used since it may run past midnight
my ( $yesterday_yyyy, $yesterday_mm, $yesterday_dd ) = get_date( - 86_400);
my $today_home;
my $results_content;
# end globally read variables

get_options_and_config();  # get command line options
$today_home = "$web_server_location_full/$opt_environment/$yyyy/$mm/$dd";

show_batch_url();

# generate a random folder for the temporary files
$temp_folder_name = create_temp_folder();

# find out what run number we are up to today for this test file
my ($run_number, $this_run_home) = create_run_number();

capture_stdout($this_run_home);

# generate the config file, and find out where it is
my ($config_file_full, $config_file_name, $config_file_path) = create_webimblaze_config_file($run_number);

# indicate that WebImblaze is running the test file
write_pending_result($run_number);

# there is now a new item in the batch, so the overall summary of everything has to be rebuilt
build_summary_of_batches();

if ($is_windows) {
    display_title_info($testfile_name, $run_number, $config_file_name);
}

my $status = call_webimblaze_with_testfile($config_file_full, $this_run_home);

write_final_result($run_number);

# the pending item in the batch is now final, so the overall summary of everything has to be rebuilt
build_summary_of_batches();

# ensure the style sheets, assets and manual files are on the web server
publish_static_files($run_number);

# tear down
remove_temp_folder($temp_folder_name, $opt_keep);

restore_stdout();

if (not $opt_capture_stdout) {
    print "Result at: http://$web_server_address/$opt_environment/$yyyy/$mm/$dd/$testfile_parent_folder_name/$testfile_name/results_$run_number/results_$run_number.xml\n";
}

if ($status) { exit 1; } else { exit 0; }

#------------------------------------------------------------------
sub call_webimblaze_with_testfile {
    my ($_config_file_full, $_this_run_home) = @_;

    my $_temp_folder_name = slash_me( $output_location . $temp_folder_name );
    #print {*STDOUT} "config_file_full: [$_config_file_full]\n";

    my $_abs_testfile_full = File::Spec->rel2abs( $testfile_full );
    my $_abs_config_file_full = File::Spec->rel2abs( $_config_file_full );
    my $_abs_temp_folder = slash_me( File::Spec->rel2abs( $_temp_folder_name ) . q{/} );

    #print {*STDOUT} "\n_abs_testfile_full: [$_abs_testfile_full]\n";
    #print {*STDOUT} "_abs_config_file_full: [$_abs_config_file_full]\n";
    #print {*STDOUT} "_abs_temp_folder: [$_abs_temp_folder]\n";

    my @_args;

    push @_args, $_abs_testfile_full;

    push @_args, '--publish-to';
    push @_args, $_this_run_home;

    if ($_abs_config_file_full) {
        push @_args, '--config';
        push @_args, $_abs_config_file_full;
    }

    if ($_abs_temp_folder) {
        push @_args, '--output';
        push @_args, $_abs_temp_folder;
    }

    if ($config_is_automation_controller eq 'true') {
        push @_args, '--autocontroller';
    }

    if ($opt_no_retry) {
        push @_args, '--ignoreretry';
    }

    if (defined $opt_capture_stdout || defined $opt_no_update_config) {
        push @_args, '--no-colour';
    }

    if ($selenium_location_full) {
        push @_args, '--selenium-binary';
        push @_args, $selenium_location_full;
    }

    if ($chromedriver_location_full) {
        push @_args, '--chromedriver-binary';
        push @_args, $chromedriver_location_full;
    }

    if ($opt_selenium_host) {
        push @_args, '--selenium-host';
        push @_args, $opt_selenium_host;
    }

    if ($opt_selenium_port) {
        push @_args, '--selenium-port';
        push @_args, $opt_selenium_port;
    }

    if ($opt_headless) {
        push @_args, '--headless';
    }

    if ($opt_keep_session) {
        push @_args, '--keep-session';
    }

    if ($opt_resume_session) {
        push @_args, '--resume-session';
    }

    push @_args, '--driver';
    push @_args, $driver;

    # WebImblaze test cases expect the current working directory to be where wi.pl is
    my $_orig_cwd = cwd;
    chdir $webimblaze_location;

    my $_status;
    my $_wi_stdout_file_full = $_this_run_home.'webimblaze_stdout.txt';
    if (defined $opt_capture_stdout) {
        print {*STDOUT} "\nLaunching wi.pl, STDOUT redirected to $_wi_stdout_file_full\n";
        print {*STDOUT} 'perl wi.pl '."@_args\n";
        $_status = system 'perl wi.pl '."@_args > $_wi_stdout_file_full 2>&1";
        print {*STDOUT} "\nwi.pl execution all done.\n";
    } else {
        # we run it like this so you can see test case execution progress "as it happens"
        my $_message = 'Start wif.pl with --capture-stdout flag to capture wi.pl standard out'."\n\n";
        $_message .= 'WebImblaze started with args: '. "@_args";
        write_file($_wi_stdout_file_full, $_message);
        $_status = system 'perl wi.pl '."@_args";
    }

    chdir $_orig_cwd;

    return $_status;
}

#------------------------------------------------------------------
sub capture_stdout {
    my ($_output_location) = @_;


    *OLD_STDOUT = *STDOUT;
    *OLD_STDERR = *STDERR;

    if (defined $opt_capture_stdout) {
        open $std_fh, '>>', $_output_location.'wif_stdout.txt' or warn "Could not create a file for WIF STDOUT\n"; ## no critic(InputOutput::RequireBriefOpen)
        *STDOUT = $std_fh; ## no critic(Variables::RequireLocalizedPunctuationVars)
        *STDERR = $std_fh; ## no critic(Variables::RequireLocalizedPunctuationVars)

        print {*STDOUT} "\nWebImblaze Framework Config:\n";
        print {*STDOUT} Data::Dumper::Dumper ( $config );
    } else {
        write_file($_output_location.'wif_stdout.txt', 'Start wif.pl with --capture-stdout flag to capture wif.pl standard out');
    }

    return;
}

#------------------------------------------------------------------
sub restore_stdout {

    if (defined $opt_capture_stdout) {
        *STDOUT = *OLD_STDOUT; ## no critic(Variables::RequireLocalizedPunctuationVars)
        *STDERR = *OLD_STDERR; ## no critic(Variables::RequireLocalizedPunctuationVars)
    }

    return;
}

#------------------------------------------------------------------
sub get_date {
    my ($_time_offset) = @_;

    ## put the specified date and time into variables - startdatetime - for recording the start time in a format an xsl stylesheet can process
    my @_MONTHS = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    #my @_WEEKDAYS = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    my ($_SECOND, $_MINUTE, $_HOUR, $_DAYOFMONTH, $_MONTH, $_YEAROFFSET, $_DAYOFWEEK, $_DAYOFYEAR, $_DAYLIGHTSAVINGS) = localtime (time + $_time_offset);
    my $_YEAR = 1900 + $_YEAROFFSET;
    #my $_YY = substr $_YEAR, 2; #year as 2 digits
    $_DAYOFMONTH = sprintf '%02d', $_DAYOFMONTH;
    #my $_WEEKOFMONTH = int(($_DAYOFMONTH-1)/7)+1;
    $_MINUTE = sprintf '%02d', $_MINUTE; #put in up to 2 leading zeros
    $_SECOND = sprintf '%02d', $_SECOND;
    $_HOUR = sprintf '%02d', $_HOUR;
    my $_TIMESECONDS = ($_HOUR * 60 * 60) + ($_MINUTE * 60) + $_SECOND;

    return $_YEAR, $_MONTHS[$_MONTH], $_DAYOFMONTH, $_HOUR, $_MINUTE, $_SECOND, $_TIMESECONDS;
}

#------------------------------------------------------------------
sub display_title_info {
    my ($_testfile_name, $_run_number, $_config_file_name) = @_;

    my $_result = `title temp\\$temp_folder_name $_config_file_name $_run_number:$_testfile_name`;

    return;
}

#------------------------------------------------------------------
sub _start_windows_process {
    my ($_command) = @_;

    my $_wmic = "wmic process call create '$_command'"; #
    my $_result = `$_wmic`;
    #print "_wmic:$_wmic\n";
    #print "$_result\n";

    my $_pid;
    if ( $_result =~ m/ProcessId = (\d+)/ ) {
        $_pid = $1;
    }

    return $_pid;
}

#------------------------------------------------------------------
sub slash_me {
    my ($_string) = @_;

    if ($is_windows) {
        $_string =~ s{/}{\\}g;
    } else {
        $_string =~ s{\\}{/}g;
    }

    return $_string;
}

#------------------------------------------------------------------
sub __port_available {
    my ($_port) = @_;

    require Socket;

    my $_family = Socket::PF_INET();
    my $_type   = Socket::SOCK_STREAM();
    my $_proto  = getprotobyname 'tcp' or die "getprotobyname: $!\n";
    my $_host   = Socket::INADDR_ANY();  # Use inet_aton for a specific interface

    socket my $_sock, $_family, $_type, $_proto  or die "socket: $!\n";
    my $_name = Socket::sockaddr_in($_port, $_host)     or die "sockaddr_in: $!\n";

    if (bind $_sock, $_name) {
        return 'available';
    }

    return 'in use';
}

sub _find_available_port {
    my ($_start_port) = @_;

    my $_max_attempts = 20;
    foreach my $i (0..$_max_attempts) {
        if (__port_available($_start_port + $i) eq 'available') {
            return $_start_port + $i;
        }
    }

    return 'none';
}

#------------------------------------------------------------------
sub _http_put {
    my ($_url, $_body) = @_;

    require HTTP::Request;

    my $_agent = LWP::UserAgent->new;
    my $_request = HTTP::Request->new('PUT', $_url);
    $_request->content_type('application/x-www-form-urlencoded');
    $_request->content($_body);
    my $_response;

    #print '_request:' . Data::Dumper::Dumper($_request). "\n\n";

    my $_max = 50;
    my $_try = 0;
    ATTEMPT:
    {
        $_response = Data::Dumper::Dumper ( $_agent->request($_request) );

        if ( ( $_response =~ m/Can[\\]\'t connect to/ ) and $_try++ < $_max ) {
            #print {*STDOUT} "WARN: cannot connect to $_url\n";
            sleep 0.1;
            redo ATTEMPT;
        }
    }

    if ( not $_response =~ m/'_rc' => '200'/ ) {
        print {*STDOUT} "\nERROR: Did not get http response 200 for PUT request\n";
        print {*STDOUT} "    url:$_url\n";
        print {*STDOUT} "   body:$_body\n\n";
    }

    #print "_response:$_response\n";

    return;
}

#------------------------------------------------------------------
sub _http_post {
    my ($_url, @_body) = @_;

    my $_response;

    my $_max = 50;
    my $_try = 0;
    ATTEMPT:
    {
        $_response = Data::Dumper::Dumper ( LWP::UserAgent->new->post($_url, \@_body) );

        if ( ( $_response =~ m/Can[\\]\'t connect to/ ) and $_try++ < $_max ) {
            #print {*STDOUT} "WARN: cannot connect to $_url\n";
            sleep 0.1;
            redo ATTEMPT;
        }
    }
    #print "_response:$_response\n";

    return;
}

#------------------------------------------------------------------
sub publish_static_files {
    my ($_run_number) = @_;

    # favourite icon
    _copy ( 'content/root/*', $web_server_location_full);

    # xsl and css stylesheets plus images
    _make_path ( $web_server_location_full.'/content/' ) ;
    _copy ( 'content/*.css', $web_server_location_full.'/content/' );
    _copy ( 'content/*.xsl', $web_server_location_full.'/content/' );
    _copy ( 'content/*.jpg', $web_server_location_full.'/content/' );

    # javascripts
    _make_path ( $web_server_location_full.'/scripts/' ) ;
    _copy ( 'scripts/*.js', $web_server_location_full.'/scripts/' );

    return;
}

#------------------------------------------------------------------
sub _copy {
    my ($_source, $_dest) = @_;

    my @_source_files = glob $_source;

    foreach my $_source_file (@_source_files) {
        if (defined $opt_capture_stdout) {
            print "copy $_source_file, $_dest\n";
        }
        copy $_source_file, $_dest;
    }

    return;
}

#------------------------------------------------------------------
sub write_final_result {
    my ($_run_number) = @_;

    _write_final_record( "$today_home/All_Batches/$opt_batch/$testfile_parent_folder_name".'_'."$testfile_name".'_'."$_run_number".'.txt', $_run_number );

    _build_batch_summary();

    return;
}

#------------------------------------------------------------------
sub _write_final_record {
    my ($_file_full, $_run_number) = @_;

    $results_content = read_file("$today_home/$testfile_parent_folder_name/$testfile_name/results_$_run_number/results_$_run_number.xml");

    if ( $results_content =~ m{</test-summary>}i ) {
        # WebImblaze ran to completion - all ok
    } else {
        # WebImblaze did not start, or crashed part way through
        _write_corrupt_record($_file_full, $_run_number, 'WebImblaze abnormal end - run manually to diagnose');
        return;
    }

    # here we parse the xml file in an eval, and capture any error returned (in $@)
    my $_message;
    my $_result = eval { XMLin($results_content) };

    if ($@) {
        $_message = $@;
        $_message =~ s{ at C:.*}{}g; # remove misleading reference Parser.pm
        $_message =~ s{\n}{}g; # remove line feeds
        #$_message =~ s/[&<>]//g;
        $_message =~ s/[&]/{AMPERSAND}/g;
        $_message =~ s/[<]/{LT}/g;
        $_message =~ s/[>]/{GT}/g;
        _write_corrupt_record($_file_full, $_run_number, "$_message in results.xml");
        print {*STDOUT} "WebImblaze results.xml could not be parsed - CORRUPT\n";
        return;
    }

    my $_start_time = $_result->{'test-summary'}->{'start-time'};
    my $_start_seconds = $_result->{'test-summary'}->{'start-seconds'};
    my $_start_date_time = $_result->{'test-summary'}->{'start-date-time'};
    my $_total_run_time = $_result->{'test-summary'}->{'total-run-time'};
    my $_max_response_time = $_result->{'test-summary'}->{'max-response-time'}; $_max_response_time = sprintf '%.1f', $_max_response_time;
    my $_test_cases_run = $_result->{'test-summary'}->{'test-cases-run'};
    #my $_test_cases_passed = $_result->{'test-summary'}->{'test-cases-passed'};
    my $_test_cases_failed = $_result->{'test-summary'}->{'test-cases-failed'};
    my $_assertion_skips = $_result->{'test-summary'}->{'assertion-skips'};
    #my $_verifications_passed = $_result->{'test-summary'}->{'verifications-passed'};
    #my $_verifications_failed = $_result->{'test-summary'}->{'verifications-failed'};
    my $_execution_aborted = $_result->{'test-summary'}->{'execution-aborted'};

    my ( $_yyyy, $_mm, $_dd, $_hour, $_minute, $_second, $_seconds ) = get_date(0);
    my $_end_date_time = "$_yyyy-$_mm-$_dd".'T'."$_hour:$_minute:$_second";

    my $_record;

    $_record .= qq|   <run id="$opt_batch">\n|;
    $_record .= qq|      <batch_name>$opt_batch</batch_name>\n|;
    $_record .= qq|      <environment>$opt_environment</environment>\n|;
    $_record .= qq|      <test_parent_folder>$testfile_parent_folder_name</test_parent_folder>\n|;
    $_record .= qq|      <test_name>$testfile_name</test_name>\n|;
    $_record .= qq|      <total_run_time>$_total_run_time</total_run_time>\n|;
    $_record .= qq|      <test_steps_failed>$_test_cases_failed</test_steps_failed>\n|;
    $_record .= qq|      <test_steps_run>$_test_cases_run</test_steps_run>\n|;
    $_record .= qq|      <assertion_skips>$_assertion_skips</assertion_skips>\n|;
    $_record .= qq|      <execution_aborted>$_execution_aborted</execution_aborted>\n|;
    $_record .= qq|      <max_response_time>$_max_response_time</max_response_time>\n|;
    $_record .= qq|      <target>$opt_target</target>\n|;
    $_record .= qq|      <yyyy>$yyyy</yyyy>\n|;
    $_record .= qq|      <mm>$mm</mm>\n|;
    $_record .= qq|      <dd>$dd</dd>\n|;
    $_record .= qq|      <run_number>$_run_number</run_number>\n|;
    $_record .= qq|      <start_time>$_start_time</start_time>\n|;
    $_record .= qq|      <start_date_time>$_start_date_time</start_date_time>\n|;
    $_record .= qq|      <end_time>$_end_date_time</end_time>\n|;
    $_record .= qq|      <start_seconds>$_start_seconds</start_seconds>\n|;
    $_record .= qq|      <end_seconds>$_seconds</end_seconds>\n|;
    $_record .= qq|      <status>NORMAL</status>\n|;
    $_record .= qq|   </run>\n|;

    _write_file ($_file_full, $_record);

    return;
}

#------------------------------------------------------------------
sub _write_corrupt_record {
    my ($_file_full, $_run_number, $_message) = @_;

    my $_record;

    my $_start_date_time = "$yyyy-$mm-$dd".'T'."$hour:$minute:$second";

    my ( $_yyyy, $_mm, $_dd, $_hour, $_minute, $_second, $_seconds ) = get_date(0);
    my $_end_date_time = "$_yyyy-$_mm-$_dd".'T'."$_hour:$_minute:$_second";

    $_record .= qq|   <run id="$opt_batch">\n|;
    $_record .= qq|      <batch_name>$opt_batch</batch_name>\n|;
    $_record .= qq|      <environment>$opt_environment</environment>\n|;
    $_record .= qq|      <test_parent_folder>$testfile_parent_folder_name</test_parent_folder>\n|;
    $_record .= qq|      <test_name>$testfile_name</test_name>\n|;
    $_record .= qq|      <total_run_time>0</total_run_time>\n|;
    $_record .= qq|      <test_steps_failed>0</test_steps_failed>\n|;
    $_record .= qq|      <test_steps_run>0</test_steps_run>\n|;
    $_record .= qq|      <assertion_skips></assertion_skips>\n|;
    $_record .= qq|      <execution_aborted>false</execution_aborted>\n|;
    $_record .= qq|      <max_response_time>0.0</max_response_time>\n|;
    $_record .= qq|      <target>$opt_target</target>\n|;
    $_record .= qq|      <yyyy>$yyyy</yyyy>\n|;
    $_record .= qq|      <mm>$mm</mm>\n|;
    $_record .= qq|      <dd>$dd</dd>\n|;
    $_record .= qq|      <run_number>$_run_number</run_number>\n|;
    $_record .= qq|      <start_time>unused</start_time>\n|;
    $_record .= qq|      <start_date_time>$_start_date_time</start_date_time>\n|;
    $_record .= qq|      <end_time>$_end_date_time</end_time>\n|;
    $_record .= qq|      <start_seconds>$seconds</start_seconds>\n|;
    $_record .= qq|      <end_seconds>$_seconds</end_seconds>\n|;
    $_record .= qq|      <status>CORRUPT</status>\n|;
    $_record .= qq|      <status_message>[$testfile_parent_folder_name/$testfile_name results.xml] $_message</status_message>\n|;
    $_record .= qq|   </run>\n|;

    _write_file ($_file_full, $_record);

    return;
}

#------------------------------------------------------------------
sub build_summary_of_batches {

    # multiple batches could be running at the same time
    my $_overall_summary_full = "$today_home/All_Batches/Summary.xml";
    _lock_file( $_overall_summary_full );

    my $_batch_summary_record_full = "$today_home/All_Batches/$opt_batch".'_summary.record';
    _lock_file( $_batch_summary_record_full ); # possibly unecessary to do this since a higher level file already has a lock

    _write_summary_record( $_batch_summary_record_full );

    # create an array containing all files representing summary records for all of todays batches
    my @_summary_records = glob("$today_home/All_Batches/".'*.record');

    # sort by date modified, ascending (-C would be date created)
    my @_sorted_summary = sort { -M $a <=> -M $b } @_summary_records;

    # write the header
    my $_summary = qq|<?xml version="1.0" encoding="ISO-8859-1"?>\n|;
#    $_summary .= qq|<?xml-stylesheet type="text/xsl" href="http://$web_server_address/content/Summary.xsl"?>\n|;
    $_summary .= qq|<?xml-stylesheet type="text/xsl" href="/content/Summary.xsl"?>\n|; ##trial domain relative url for Summary.xsl
    $_summary .= qq|<summary version="2.0">\n|;
    $_summary .= qq|    <channel>\n|;

    # write all the batch records
    foreach (@_sorted_summary) {
        $_summary .= read_file($_);
    }

    # write the footer
    $_summary .= qq|    </channel>\n|;
    $_summary .= qq|</summary>\n|;

    # save the file to todays area, and a copy to environment root
    _write_file ( $_overall_summary_full, $_summary );
    _write_file ( $web_server_location_full."/$opt_environment/Summary.xml", $_summary );

    # unlock the locked files
    _unlock_file( $_batch_summary_record_full );
    _unlock_file( $_overall_summary_full );

    return;
}

#------------------------------------------------------------------
sub _write_summary_record {
    my ($_file_full) = @_;

    my $_twig;

    my $_max = 5;
    my $_try = 0;
    ATTEMPT:
    {
        $_twig = XML::Twig->new();
        eval {
            $_twig->parsefile( "$today_home/All_Batches/$opt_batch".'.xml' );
        }; # eval needs a semicolon

        if ( $@ and $_try++ < $_max ) {
            print {*STDOUT} "WARN: $@    Failed try $_try to parse"."$today_home/All_Batches/$opt_batch".".xml\n";
            sleep rand $_try;
            redo ATTEMPT;
        }
    }

    BatchSummary::_calculate_stats($_twig);

    my $_record;

    $_record .= qq|      <title>$opt_environment Summary</title>\n|;
    $_record .= qq|      <link>http://$web_server_address/$opt_environment/$yesterday_yyyy/$yesterday_mm/$yesterday_dd/All_Batches/Summary.xml</link>\n|;
    $_record .= qq|      <description>WebImblaze Framework Batch Summary</description>\n|;
    $_record .= qq|      <item>\n|;

    $_record .= qq|         <title>|;
    $_record .= BatchSummary::_build_overall_summary_text(
        $opt_batch,
        $opt_target,
        $dd,
        $mm
    );
    $_record .= qq|</title>\n|;

    $_record .= qq|         <link>http://$web_server_address/$opt_environment/$yyyy/$mm/$dd/All_Batches/$opt_batch.xml</link>\n|;
    $_record .= qq|         <description></description>\n|;
    $_record .= qq|         <pubDate>$dd/$mm/$yyyy $hour:$minute</pubDate>\n|;
    $_record .= qq|      </item>\n|;

    _write_file ($_file_full, $_record);

    return;
}

#------------------------------------------------------------------
sub write_pending_result {
    my ($_run_number) = @_;

    _make_path( "$today_home/All_Batches/$opt_batch" );

    _write_pending_record( "$today_home/All_Batches/$opt_batch/$testfile_parent_folder_name".'_'."$testfile_name".'_'."$_run_number".'.txt', $_run_number );

    _build_batch_summary();

    return;
}

#------------------------------------------------------------------
sub _build_batch_summary {

    # lock batch xml file so parallel instances of wif.pl cannot update it
    my $_batch_full = "$today_home/All_Batches/$opt_batch".'.xml';
    _lock_file($_batch_full);

    # create an array containing all files representent runs in the batch
    my @_runs = glob("$today_home/All_Batches/$opt_batch/".'*.txt');

    # sort by date created, ascending
    my @_sorted_runs = reverse sort { -C $a <=> -C $b } @_runs;

    # write the header
    my $_batch = qq|<?xml version="1.0" encoding="ISO-8859-1"?>\n|;
    $_batch .= qq|<?xml-stylesheet type="text/xsl" href="/content/Batch.xsl"?>\n|;
    $_batch .= qq|<batch>\n|;

    # write all the run records
    foreach (@_sorted_runs) {
        $_batch .= read_file($_);
    }

    # write the footer
    $_batch .= qq|</batch>\n|;

    # dump batch xml file from memory into file system
    _write_file ("$today_home/All_Batches/$opt_batch".'.xml', $_batch);

    # unlock batch xml file
    _unlock_file($_batch_full);

    return;
}


#------------------------------------------------------------------
sub _write_file {
    my ($_file_full, $_file_content) = @_;

    my $_max = 10;
    my $_try = 0;
    ATTEMPT:
    {
        eval {
            open my $_FILE, '>', "$_file_full" or die "\nWARN: Failed to open $_file_full for writing\n\n";
            print {$_FILE} $_file_content;
            close $_FILE or die "\nWARN: Failed to close $_file_full\n\n";
        }; # eval needs a semicolon

        if ( $@ and $_try++ < $_max ) {
            print {*STDOUT} "WARN: $@    Failed try $_try to write file\n";
            sleep rand $_try;
            redo ATTEMPT;
        }

        if ( $@ ) {
            print {*STDOUT} "ERROR: Failed $_max attempts to write file $_file_full, gave up.\n";
        }

    }
    print {*STDOUT} "...(try $_try) wrote file $_file_full \n" if defined $opt_capture_stdout;

    return;
}

#------------------------------------------------------------------
sub _write_pending_record {
    my ($_file_full, $_run_number) = @_;

    my $_record;

    my $_start_date_time = "$yyyy-$mm-$dd".'T'."$hour:$minute:$second";

    $_record .= qq|   <run id="$opt_batch">\n|;
    $_record .= qq|      <batch_name>$opt_batch</batch_name>\n|;
    $_record .= qq|      <environment>$opt_environment</environment>\n|;
    $_record .= qq|      <test_parent_folder>$testfile_parent_folder_name</test_parent_folder>\n|;
    $_record .= qq|      <test_name>$testfile_name</test_name>\n|;
    $_record .= qq|      <total_run_time>0</total_run_time>\n|;
    $_record .= qq|      <test_steps_failed>0</test_steps_failed>\n|;
    $_record .= qq|      <test_steps_run>0</test_steps_run>\n|;
    $_record .= qq|      <assertion_skips></assertion_skips>\n|;
    $_record .= qq|      <execution_aborted>false</execution_aborted>\n|;
    $_record .= qq|      <max_response_time>0.0</max_response_time>\n|;
    $_record .= qq|      <target>$opt_target</target>\n|;
    $_record .= qq|      <yyyy>$yyyy</yyyy>\n|;
    $_record .= qq|      <mm>$mm</mm>\n|;
    $_record .= qq|      <dd>$dd</dd>\n|;
    $_record .= qq|      <run_number>$_run_number</run_number>\n|;
    $_record .= qq|      <start_time>unused</start_time>\n|;
    $_record .= qq|      <start_date_time>$_start_date_time</start_date_time>\n|;
    $_record .= qq|      <end_time>PENDING</end_time>\n|;
    $_record .= qq|      <start_seconds>$seconds</start_seconds>\n|;
    $_record .= qq|      <end_seconds>$seconds</end_seconds>\n|;
    $_record .= qq|      <status>NORMAL</status>\n|;
    $_record .= qq|   </run>\n|;

    _write_file ($_file_full, $_record);

    return;
}

#------------------------------------------------------------------
sub deprecated_check_testfile_xml_parses_ok {

    my $_xml = read_file($testfile_full);

    # for convenience, WebImblaze allows ampersand and less than to appear in xml data, so this needs to be masked
    $_xml =~ s/&/{AMPERSAND}/g;
    while ( $_xml =~ s/\w\s*=\s*"[^"]*\K<(?!case)([^"]*")/{LESSTHAN}$1/sg ) {}
    while ( $_xml =~ s/\w\s*=\s*'[^']*\K<(?!case)([^']*')/{LESSTHAN}$1/sg ) {}

    # here we parse the xml file in an eval, and capture any error returned (in $@)
    my $_message;
    my $_result = eval { XMLin($_xml) };

    if ($@) {
        $_message = $@;
        $_message =~ s{XML::Simple.*\n}{}g; # remove misleading line number reference
        die "\n".$_message." in $testfile_full\n";
    }

    return;
}

#------------------------------------------------------------------
sub _make_path {

    my ($_path) = @_;

    make_path( "$_path", {error => \my $err} );

    if (@$err) { die "\nThis user account needs permission to create $_path\n" };

    return;
}

#------------------------------------------------------------------
sub create_run_number {

    if (not -e "$web_server_location_full" ) {
        die "\nWeb server location of $web_server_location_full does not exist\n";
    }

    # if they do not exist already, folders are created for this test file for todays date
    _make_path( "$web_server_location_full/$opt_environment/$yyyy/$mm" );
    _make_path( "$today_home/$testfile_parent_folder_name/$testfile_name" );

    my $_run_number_full = "$today_home/$testfile_parent_folder_name/$testfile_name/Run_Number.txt";
    _lock_file($_run_number_full);
    my $_run_number = _increment_run_number($_run_number_full);
    _unlock_file($_run_number_full);

    # create a folder for this run number
    my $_this_run_home = "$today_home/$testfile_parent_folder_name/$testfile_name/results_$_run_number/";
    _make_path( $_this_run_home );

    return $_run_number, $_this_run_home;
}

#------------------------------------------------------------------
sub _increment_run_number {
    my ($_run_number_full) = @_;

    my $_run_number;
    if (-e $_run_number_full) {
        my $_run_number_string = read_file($_run_number_full);
        if ( $_run_number_string =~ m/([\d]*)/ ) {
            $_run_number = $1;
        }
    }

    if (! $_run_number) {
        $_run_number = 1000;
    }

    $_run_number++;

    open my $RUNFILE, '>', "$_run_number_full" or die "\nERROR: Failed to create $_run_number_full\n\n";
    print {$RUNFILE} "$_run_number";
    close $RUNFILE or die "\nERROR: Failed to close $_run_number_full\n\n";

    return $_run_number;
}

#------------------------------------------------------------------
sub _unlock_file {
    my ($_file_to_unlock_full) = @_;

    my $_unlocked_file_indicator = $_file_to_unlock_full.'_Unlocked';
    my $_locked_file_indicator = _prepend_to_filename('Locked_', $_file_to_unlock_full);
    #if (defined $opt_capture_stdout) {
    #    print "    move\n        $_locked_file_indicator".'_'."$temp_folder_name\n        ".$_unlocked_file_indicator."\n\n";
    #}
    move $_locked_file_indicator."_$temp_folder_name", $_unlocked_file_indicator;

    return;
}

#------------------------------------------------------------------
sub _lock_file {
    my ($_file_to_lock_full) = @_;

    # first the file we want to lock may not even exist, in which case we create it
    my $_unlocked_file_indicator = $_file_to_lock_full.'_Unlocked';
    my $_locked_file_indicator = _prepend_to_filename('Locked_', $_file_to_lock_full);
    if (not -e "$_unlocked_file_indicator" ) {
        #print "file is not unlocked: $_unlocked_file_indicator\n";
        # file is not unlocked
        if (not glob("$_locked_file_indicator".'_*') ) {
            #print "file is not locked either: $_locked_file_indicator".'_*'."\n";
            # file is not locked either, so it must not exist
            # so we can create a file indicating that the file is unlocked
            _touch($_unlocked_file_indicator);
        }
    }

    # now to actually lock the file
    # we do this by renaming the Unlocked indicator file to the name Locked_filename.filesufix_tempfoldername
    # the temp folder name is unique to this process
    my $_max = 6;
    my $_try = 0;
    ATTEMPT:
    {
        eval {
            #print "move\n$_unlocked_file_indicator\n"."$_locked_file_indicator".'_'."$temp_folder_name\n\n";
            move $_unlocked_file_indicator, $_locked_file_indicator.'_'.$temp_folder_name or die "Cannot lock file\n";
        }; # eval needs a semicolon

        # if we failed to lock the file but there are attempts remaining
        if ( $@ and $_try++ < $_max ) {
            print {*STDOUT} "WARN: $@    Failed try $_try to lock $_file_to_lock_full\n    Want lock :$_locked_file_indicator".q{_}."$temp_folder_name\n";
            my @_locked = glob $_locked_file_indicator.'_*';
            foreach (@_locked) {
                print '    found lock:'.$_."\n";
            }
            if (not -e $_unlocked_file_indicator) {
                print '    no unlock :'.$_unlocked_file_indicator."\n";
            } else {
                print '    unlocked!!:'.$_unlocked_file_indicator."\n";
            }
            sleep rand $_try;
            redo ATTEMPT;
        }
    }

    if ($@) {
        # we can get here if a parallel process aborts at exactly the wrong spot
        # so we forcibly lock the file
        print {*STDOUT} "\nError: $@ Failed to lock $_file_to_lock_full after $_max tries\n\n";
        print {*STDOUT} "Executing fail safe - deleting lock and creating our own lock\n\n";
        unlink glob($_locked_file_indicator.'_*');
        unlink $_unlocked_file_indicator;
        _touch($_locked_file_indicator.'_'.$temp_folder_name);
        # this might screw things up a little, but it prevents things being screwed up a lot (i.e. no more test results for the rest of the day)
        # people just have to rerun their most recent tests and all should be fine
    } else {
        #print "Successfully locked: $_file_to_lock_full\n\n\n";
    }

    # now we have locked the file by fair means or by foul

    return;
}


#------------------------------------------------------------------
sub _touch {
    my ($_file_full) = @_;

    open my $TOUCHFILE, '>', "$_file_full" or warn "\nERROR: Failed to create $_file_full\n\n";
    close $TOUCHFILE or warn "\nERROR: Failed to close $_file_full\n\n";

    return;
}

#------------------------------------------------------------------
sub _prepend_to_filename {
    my ($_string, $_file_full) = @_;

    my ($_file_name, $_file_path, $_file_suffix) = fileparse($_file_full, ('\.xml', '\.txt', '\.html', '\.test', '\.wi', '\.record'));

    return $_file_path.$_string.$_file_name.$_file_suffix;

}

#------------------------------------------------------------------
sub create_webimblaze_config_file {
    my ($_run_number) = @_;

    $target_config = Config::Tiny->read( "environment_config/$opt_environment/$opt_target.config" );

    $environment_config = Config::Tiny->read( "environment_config/$opt_environment.config" );

    if (-e 'environment_config/_global.config') {
        $global_config = Config::Tiny->read( 'environment_config/_global.config' );
    }

    my $_webimblaze_config = "<root>\n";
    $_webimblaze_config .= _write_webimblaze_config('main');
    $_webimblaze_config .= _write_webimblaze_config('userdefined');
    $_webimblaze_config .= _write_webimblaze_config('autoassertions');
    $_webimblaze_config .= _write_webimblaze_config('smartassertions');
    $_webimblaze_config .= _write_webimblaze_config('baseurl_subs');
    $_webimblaze_config .= _write_webimblaze_config('content_subs');
    $_webimblaze_config .= _write_webimblaze_wif_config($_run_number);
    $_webimblaze_config .=  "</root>\n";

    my $_config_file_full = "$today_home/$testfile_parent_folder_name/$testfile_name/results_$_run_number/$opt_target.config";
    _write_file($_config_file_full, $_webimblaze_config);

    my ($_config_file_name, $_config_file_path) = fileparse($_config_file_full,'\.config');

    return $_config_file_full, $_config_file_name, $_config_file_path;
}

#------------------------------------------------------------------
sub _check_target {
    my ($_env, $_orig_target) = @_;

    # if the target exists for the environment, then we are done
    if (-e "environment_config/$_env/$_orig_target.config") {
        return $_env, $_orig_target;
    }

    # perhaps the target is an alias within the current environment
    my $_target = _get_alias($_env, $_orig_target);
    if (-e "environment_config/$_env/$_target.config") {
        return $_env, $_target;
    }

    # ok, maybe the target is for another environment, lets check them all and switch to that environment if found
    my @_files = glob 'environment_config/*';
    foreach (@_files) {
        if (-d $_) {
            my $_candidate = $_;
            $_candidate =~ s{.*/}{}; # remove environment_config/
            if (-e "environment_config/$_candidate/$_orig_target.config") {
                print {*STDOUT} "Switched Environment [$_env] to [$_candidate]\n";
                return $_candidate, $_orig_target;
            }
            $_target = _get_alias($_candidate, $_orig_target);
            if (-e "environment_config/$_candidate/$_target.config") {
                print {*STDOUT} "Switched Environment [$_env] to [$_candidate]\n";
                return $_candidate, $_target;
            }
        }
    }

    if ( not -e "environment_config/$opt_environment.config" ) {
        die "Could not find environment_config/$opt_environment.config\n";
    }

    if ( not -e "environment_config/$opt_environment" ) {
        die "Could not find folder environment_config/$opt_environment\n";
    }

    if (not -e "environment_config/$opt_environment/$opt_target.config") {
        die "Could not find environment_config/$opt_environment/$opt_target.config\n";
    }

    return $_env, $_orig_target;
}

#------------------------------------------------------------------
sub _get_alias {
    my ($_env, $_orig_target) = @_;

    my $_target = $_orig_target;
    # if $opt_target contains an alias, change it to the real value
    my $_alias = Config::Tiny->new;
    if (-e "environment_config/$_env/_alias.config") {
        $_alias = Config::Tiny->read( "environment_config/$_env/_alias.config" );

        if (defined $_alias->{_}->{$_orig_target}) {
            $_target = $_alias->{_}->{$_orig_target};
            print {*STDOUT} "[$_orig_target] is alias for [$_target]\n";
        }
    }

    return $_target;
}

#------------------------------------------------------------------
sub _write_webimblaze_config {
    my ($_section) = @_;

    my $_config;

    # config parameters defined under [main] will be written at the root level of the WebImblaze config
    my $_indent = q{};
    if (not $_section eq 'main') {
        $_indent = q{    };
        $_config .= "    <$_section>\n";
    }

    foreach my $_parameter (sort keys %{$target_config->{$_section}}) {
        $_config .= "    $_indent<$_parameter>";
        $_config .= "$target_config->{$_section}->{$_parameter}";
        $_config .= "</$_parameter>\n";
    }

    foreach my $_parameter (sort keys %{$environment_config->{$_section}}) {
        if ( defined $target_config->{$_section}->{$_parameter} ) {
            # _target_config takes priority - parameter has already been written
            next;
        }

        $_config .= "    $_indent<$_parameter>";
        $_config .= "$environment_config->{$_section}->{$_parameter}";
        $_config .= "</$_parameter>\n";
    }

    foreach my $_parameter (sort keys %{$global_config->{$_section}}) {
        if ( defined $target_config->{$_section}->{$_parameter} ) {
            # _target_config takes priority - parameter has already been written
            next;
        }

        if ( defined $environment_config->{$_section}->{$_parameter} ) {
            # _environment_config takes priority - parameter has already been written
            next;
        }

        $_config .= "    $_indent<$_parameter>";
        $_config .= "$global_config->{$_section}->{$_parameter}";
        $_config .= "</$_parameter>\n";
    }

    if (not $_section eq 'main') {
        $_config .= "    </$_section>\n";
    }

    return $_config;
}

#------------------------------------------------------------------
sub _write_webimblaze_wif_config {
    my ($_run_number) = @_;

    my $_config;

    $_config .= "    <wif>\n";
    $_config .= "        <environment>$opt_environment</environment>\n";
    $_config .= "        <batch>$opt_batch</batch>\n";
    $_config .= "        <folder>$testfile_parent_folder_name</folder>\n";
    $_config .= "        <run_number>$_run_number</run_number>\n";
    $_config .= "        <yyyy>$yyyy</yyyy>\n";
    $_config .= "        <mm>$mm</mm>\n";
    $_config .= "        <dd>$dd</dd>\n";
    $_config .= "    </wif>\n";

    return $_config;
}
#------------------------------------------------------------------
sub get_web_server_location {

    my $_cmd = 'subs\get_web_server_location.pl';
    my $_server_location = `$_cmd`;
    #print {*STDOUT} "$server_location [$_server_location]\n";

    return $_server_location;
}

#------------------------------------------------------------------
sub create_temp_folder {
    my $_random = int rand 99_999;
    $_random = sprintf '%05d', $_random; # add some leading zeros

    my $_random_folder = $opt_target . '_' . $testfile_name . '_' . $_random;
    _make_path ($output_location . $_random_folder);

    return $_random_folder;
}

#------------------------------------------------------------------
sub remove_temp_folder {
    my ($_remove_folder, $_opt_keep) = @_;

    if (defined $_opt_keep) {
        # user has decided to keep temporary files
        print {*STDOUT} "\nKept temporary folder $_remove_folder\n";
        return;
    }

    my $_max = 30;
    my $_try = 0;

    ATTEMPT:
    {
        remove_tree $output_location . $_remove_folder, {error =>  \my $_error};

        if ( @$_error and $_try++ < $_max ) {
            #print "\nError: $@ Failed to remove folder, trying again...\n";
            sleep 0.1;
            redo ATTEMPT;
        }
        if ( @$_error and $_try++ > $_max ) {
            print "\nError: Failed to remove folder, given up after $_max tries\n";
        }
    }

    if ($@) {
        print {*STDOUT} "\nError: $@ Failed to remove folder $output_location$_remove_folder after $_max tries\n\n";
    }

    return;
}

#------------------------------------------------------------------
sub _create_default_config {

    my $_web_server_location_full = 'web_server_location_full=/var/www/html'."\n";
    my $_chromedriver_location_full = 'chromedriver_location_full=$HOME/selenium/chromedriver'."\n";
    my $_selenium_location_full = 'selenium_location_full=$HOME/selenium/selenium-server-3-standalone.jar'."\n";
    if ( $is_windows ) {
        $_web_server_location_full = 'web_server_location_full=C:\Apache24\htdocs'."\n";
        $_chromedriver_location_full = 'chromedriver_location_full=C:\selenium\chromedriver.exe'."\n";
        $_selenium_location_full = 'selenium_location_full=C:\selenium\selenium-server-3-standalone.jar'."\n";
    }

    my $_config;
    $_config .= '[main]'."\n";
    $_config .= 'batch=example_batch'."\n";
    $_config .= 'environment=DEV'."\n";
    $_config .= 'is_automation_controller=false'."\n";
    $_config .= 'target=team1'."\n";
    $_config .= q{}."\n";
    $_config .= '[path]'."\n";
    $_config .= $_selenium_location_full;
    $_config .= "driver=$DEFAULT_DRIVER\n";
    $_config .= $_chromedriver_location_full;
    $_config .= 'testfile_full=../WebImblaze/examples/get.xml'."\n";
    $_config .= 'web_server_address=localhost'."\n";
    $_config .= $_web_server_location_full;
    $_config .= "webimblaze_location=$DEFAULT_WEBIMBLAZE_LOCATION\n";
    $_config .= "output_location=$DEFAULT_OUTPUT_LOCATION\n";

    write_file('wif.config', $_config);

    return;
}

#------------------------------------------------------------------
sub _read_config {

    if (defined $ARGV[0]) {
        if (lc $ARGV[0] eq '--create-config') {
            _create_default_config();
            print "\nDefault wif.config created.\n\nPlease review the config and refer to the manual for correct settings.\n";
            exit;
        }
    }

    if (not -e 'wif.config') {
        my $_message = "\nERROR: ./wif.config not found\n";
        $_message .= "\nTo create default config file, use: perl wif.pl --create-config\n";
        die $_message;
    }

    $config = Config::Tiny->read( 'wif.config' );

    # main
    $opt_target = $config->{main}->{target};
    $opt_batch = $config->{main}->{batch};
    $opt_environment = $config->{main}->{environment};
    $config_is_automation_controller = $config->{main}->{is_automation_controller};

    # path
    $testfile_full = $config->{path}->{testfile_full};
    $selenium_location_full = $config->{path}->{selenium_location_full};
    $driver = $config->{path}->{driver};
    $chromedriver_location_full = $config->{path}->{chromedriver_location_full};
    $web_server_location_full = $config->{path}->{web_server_location_full};
    $web_server_address = $config->{path}->{web_server_address};
    $webimblaze_location = $config->{path}->{webimblaze_location};
    $output_location = $config->{path}->{output_location};

    $webimblaze_location //= $DEFAULT_WEBIMBLAZE_LOCATION;
    $output_location //= $DEFAULT_OUTPUT_LOCATION;
    $driver //= $LEGACY_DEFAULT_DRIVER;

    # normalise config
    if (lc $config_is_automation_controller eq 'true' ) {
        $config_is_automation_controller = 'true';
    } else {
        $config_is_automation_controller = 'false';
    }

    return;
}

#------------------------------------------------------------------
sub _write_config {

    # main
    $config->{main}->{target} = $opt_target;
    $config->{main}->{batch} = $opt_batch;
    $config->{main}->{environment} = $opt_environment;
    $config->{main}->{is_automation_controller} = $config_is_automation_controller;

    # path
    $config->{path}->{testfile_full} = $testfile_full;
    $config->{path}->{selenium_location_full} = $selenium_location_full;
    $config->{path}->{driver} = $driver;
    $config->{path}->{chromedriver_location_full} = $chromedriver_location_full;
    $config->{path}->{web_server_location_full} = $web_server_location_full;
    $config->{path}->{web_server_address} = $web_server_address;
    $config->{path}->{webimblaze_location} = $webimblaze_location;
    $config->{path}->{output_location} = $output_location;

    $config->write( 'wif.config' );

    return;
}

#------------------------------------------------------------------
sub linux_me {
    my ($_string) = @_;

    $_string =~ s{\\}{/}g;

    return $_string;
}

#------------------------------------------------------------------
sub _locate_file {
    my ($_file) = @_;

    if (-e $start_folder_full.'/'.$testfile_full) {
        return $start_folder_full.'/'.$testfile_full;
    }

    require File::Find::Rule;

    my ($_file_name, $_file_path) = fileparse( $_file, ('\.xml', '\.test', '\.wi', '\.t') );
    $_file_name .= q{.*};

    my @_folders = ('tests', '../WebImblaze', '../WebImblaze-Selenium', q{.});

    my @_files = File::Find::Rule->file()
                                 ->name( $_file_name )
                                 ->in( @_folders );

    if (not @_files) {
        return $_file;
    }

    # when substeps/runif passed in, will find selftest/substeps/runif.test instead of selftest/runif.test
    my $_best_match = $_files[0]; # fail safe, in practice best match will be last file in list unless more path specified
    my $_linux_file = linux_me($_file); # file find always returns paths in Linux format
    foreach my $_match (@_files) {
        if ( $_match =~ /$_linux_file/ ) {
            $_best_match = $_match;
        }
    }

    print  {*STDOUT} "Test case file [$_best_match]\n";

    return $_best_match;
}

#------------------------------------------------------------------
sub get_options_and_config {

    _read_config();

    # config file definition wins over hard coded defaults
    if (not defined $opt_environment) { $opt_environment = 'DEV'; }; # default the environment name
    if (not defined $opt_batch) { $opt_batch = 'Default_Batch'; }; # default the batch

    # options specified at the command line win over those defined in wif.config
    Getopt::Long::Configure('bundling');
    GetOptions(
        't|target=s'                => \$opt_target,
        'b|batch=s'                 => \$opt_batch,
        'e|env=s'                   => \$opt_environment,
        'g|selenium-host=s'         => \$opt_selenium_host,
        'o|selenium-port=s'         => \$opt_selenium_port,
        'l|headless'                => \$opt_headless,
        'n|no-retry'                => \$opt_no_retry,
        'u|no-update-config'        => \$opt_no_update_config,
        'c|capture-stdout'          => \$opt_capture_stdout,
        'k|keep'                    => \$opt_keep,
        's|keep-session'            => \$opt_keep_session,
        'm|resume-session'          => \$opt_resume_session,
        'v|V|version'               => \$opt_version,
        'h|help'                    => \$opt_help,
        'w|show-batch-url'          => \$opt_show_batch_url,
        )
        or do {
            print_usage();
            exit;
        };
    if ($opt_version) {
        print_version();
        exit;
    }

    if ($opt_help) {
        print_version();
        print_usage();
        print "\nTest case file $testfile_full\n";
        print "Target         [$opt_environment] $opt_target\n";
        print "Batch          $opt_batch\n";
        exit;
    }

    # ensure we were supplied with a test case file - either from command line, or wif.config
    if (($#ARGV + 1) < 1) {
        if (not defined $testfile_full) {
            print {*STDOUT} "\nERROR: No test file name specified at command line or found in wif.config\n";
            print_usage();
            exit;
        }
    } else {
        $testfile_full = $ARGV[0];
    }

    if (not -e $testfile_full) {
        $testfile_full = _locate_file($testfile_full);
        if (not -e $testfile_full) {
            die "\n\nERROR: no such test file found $testfile_full\n";
        }
    }

    ($testfile_name, $testfile_path) = fileparse( $testfile_full, ('\.xml', '\.txt', '\.test', '\.wi', '\.t') );

    my $_abs_testfile_full = File::Spec->rel2abs( $testfile_full );
    $testfile_parent_folder_name =  basename ( dirname($_abs_testfile_full) );
    # done like this in case we were told the test file is in "./" - we need the complete name for reporting purposes


    if (not defined $opt_target) {
        print {*STDOUT} "\n\nERROR: Target sub environment name must be specified\n";
        exit;
    }

    ($opt_environment, $opt_target) = _check_target($opt_environment, $opt_target);

    # now we know what the preferred settings are, save them for next time
    if ( not defined $opt_no_update_config ) {
        _write_config();
    }

    # if we are keeping the browser session, we have to keep the temporary folder as well - since chromedriver and the selenium log will still be locked
    if ($opt_keep_session) {
        $opt_keep = 1;
    }

    return;
}

sub print_version {
    print {*STDOUT} "\nWebImblaze-Framework version $VERSION\nFor more info: https://github.com/Qarj/WebImblaze-Framework\n\n";
    return;
}

sub show_batch_url {
    if ($opt_show_batch_url) {
        print( "http://$web_server_address/$opt_environment/$yyyy/$mm/$dd/All_Batches/$opt_batch.xml" );
        exit;
    }

    return;
}

sub print_usage {
    print <<'EOB'

Usage: perl wif.pl tests/testfilename.test <<options>>

-t|--target                 target environment handle           --target skynet
-b|--batch                  batch name for grouping results     --batch SmokeTests
-e|--env                    high level environment DEV, LIVE    --env DEV
-g|--selenium-host          use selenium (grid) host at         --selenium-host 10.44.1.2
-o|--selenium-port          selenium (grid) port                --selenium-port 4444
-l|--headless               start chrome in headless mode       --headless
-n|--no-retry               do not invoke retries
-u|--no-update-config       do not update config to reflect options
-c|--capture-stdout         capture wif.pl and wi.pl STDOUT
-k|--keep                   keep temporary files
-s|--keep-session           keep browser session
-m|--resume-session         use the browser session kept by --keep-session

   --create-config          create a wif.config file with default values
                            WARNING! Will overwrite the current wif.config

perl wif.pl -v|--version
perl wif.pl -h|--help
perl wif.pl -w|--show-batch-url
EOB
;
return;
}
#------------------------------------------------------------------
