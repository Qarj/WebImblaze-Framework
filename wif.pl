#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.01';

#    WebInjectFramework is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    WebInjectFramework is distributed in the hope that it will be useful,
#    but without any warranty; without even the implied warranty of
#    merchantability or fitness for a particular purpose.  See the
#    GNU General Public License for more details.

#    Example: 
#              wif.pl ../WebInject/examples/command.xml --target my_sub_environment
#              wif.pl ../WebInject/examples/selenium.xml --target my_sub_environment

use Getopt::Long;
use File::Basename;
use File::Spec;
use Cwd;
use Time::HiRes 'time','sleep';
use File::Slurp;
use File::Copy qw(copy);
use Config::Tiny;
use XML::Simple;

local $| = 1; # don't buffer output to STDOUT

# start globally read/write variables declaration - only variables declared here will be read/written directly from subs
my $har_file_content;
my ( $opt_version, $opt_target, $opt_batch, $opt_environment, $opt_use_browsermob_proxy, $opt_no_retry, $opt_help, $testfile_full, $testfile_name, $testfile_path );
my ( $opt_keep, $opt_no_update_config );
my ( $config_is_automation_controller );
my ( $web_server_location_full, $selenium_location_full );
my ( $temp_folder_name );
my $config = Config::Tiny->new;
my $target_config = Config::Tiny->new;
my $global_config = Config::Tiny->new;
my $environment_config = Config::Tiny->new;
my $WEBINJECT_CONFIG;
# end globally read/write variables

get_options_and_config();  # get command line options

# generate a random folder for the temporary files
$temp_folder_name = create_temp_folder();

# check the testfile to ensure the XML parses - will die if it doesn't
check_testfile_xml_parses_ok();

# generate the config file, and find out where it is
my ($config_file_full, $config_file_name, $config_file_path) = create_webinject_config_file();

# find out what run number we are up to today for this testcase file
my $run_number = get_run_number($opt_environment, $testfile_full);

# indicate that WebInject is running the testfile
write_pending_result($opt_environment, $opt_target, $testfile_full, $opt_batch, $run_number);

my $webinject_path = get_webinject_location();

my $testfile_contains_selenium = does_testfile_contain_selenium($testfile_full);
#print "testfile_contains_selenium:$testfile_contains_selenium\n";

my $proxy_port = start_browsermob_proxy($testfile_contains_selenium, $opt_use_browsermob_proxy);

my $selenium_port = start_selenium_server($testfile_contains_selenium);
#print "selenium_port:$selenium_port\n";

display_title_info($testfile_name, $run_number, $config_file_name, $selenium_port, $proxy_port);

call_webinject_with_testfile($testfile_full, $config_file_full, $config_is_automation_controller, $webinject_path, $opt_no_retry, $testfile_contains_selenium, $selenium_port, $proxy_port);

shutdown_selenium_server($selenium_port);

write_har_file($proxy_port);

shutdown_proxy($proxy_port);

report_har_file_urls($proxy_port);

publish_results_on_web_server($opt_environment, $opt_target, $testfile_full, $opt_batch, $run_number);

write_final_result($opt_environment, $opt_target, $testfile_full, $opt_batch, $run_number);

# ensure the stylesheets, assets and manual files are on the web server
publish_static_files($opt_environment);

# tear down
remove_temp_folder($temp_folder_name, $opt_keep);


#------------------------------------------------------------------
sub call_webinject_with_testfile {
    my ($_testfile_full, $_config_file_full, $_is_automation_controller, $_webinject_path, $_no_retry, $_testfile_contains_selenium, $_selenium_port, $_proxy_port) = @_;

    my $_temp_folder_name = 'temp/' . $temp_folder_name;

    #print {*STDOUT} "config_file_full: [$_config_file_full]\n";

    my $_abs_testfile_full = File::Spec->rel2abs( $_testfile_full );
    my $_abs_config_file_full = File::Spec->rel2abs( $_config_file_full );
    my $_abs_temp_folder = File::Spec->rel2abs( $_temp_folder_name ) . q{/};

    #print {*STDOUT} "\n_abs_testfile_full: [$_abs_testfile_full]\n";
    #print {*STDOUT} "_abs_config_file_full: [$_abs_config_file_full]\n";
    #print {*SDDOUT} "_abs_temp_folder: [$_abs_temp_folder]\n";

    my @_args;

    push @_args, $_abs_testfile_full;

    if ($_abs_config_file_full) {
        push @_args, '--config';
        push @_args, $_abs_config_file_full;
    }

    if ($_abs_temp_folder) {
        push @_args, '--output';
        push @_args, $_abs_temp_folder;
    }

    if ($_is_automation_controller eq 'true') {
        push @_args, '--autocontroller';
    }

    if ($_no_retry) {
        push @_args, '--ignoreretry';
    }

    # Selenium only options
    if ($_testfile_contains_selenium) {

        if ($_proxy_port) {
            push @_args, '--proxy';
            push @_args, 'localhost:' . $_proxy_port;
        }

        push @_args, '--port';
        push @_args, $_selenium_port;

        # for now we hardcode the browser to Chrome
        push @_args, '--driver';
        push @_args, 'chrome';

    }

    # WebInject test cases expect the current working directory to be where webinject.pl is
    my $_orig_cwd = cwd;
    chdir $_webinject_path;

    # we run it like this so you can see test case execution progress "as it happens"
    system 'webinject.pl', @_args;

    chdir $_orig_cwd;

    return;
}


#------------------------------------------------------------------
sub display_title_info {
    my ($_testfile_name, $_run_number, $_config_file_name, $_selenium_port, $_proxy_port) = @_;

    my $_selenium_port_info = q{};
    if (defined $_selenium_port) {
        $_selenium_port_info = " [Selenium Port:$_selenium_port]";
    }

    my $_proxy_port_info = q{};
    if (defined $_proxy_port) {
        $_proxy_port_info = " [Proxy Port:$_proxy_port]";
    }

    my $_result = `title temp\\$temp_folder_name $_config_file_name $_run_number:$_testfile_name$_selenium_port_info$_proxy_port_info`;

    return;
}

#------------------------------------------------------------------
sub report_har_file_urls {
    my ($_proxy_port) = @_;

    if (not defined $_proxy_port) {
        return;
    }

    my $_filename = 'temp/' . $temp_folder_name . '/URLs.txt';
    open my $_fh, '>', $_filename or die "Could not open file '$_filename' $!\n";
    binmode $_fh, ':encoding(UTF-8)'; # set binary mode and utf8 character set

    my $doublequote = "\x22"; ## no critic(ValuesAndExpressions::ProhibitEscapedCharacters)
    while ( $har_file_content =~ m/"url":$doublequote([^$doublequote]*)$doublequote/g ) {
        print {$_fh} "$1\n";
    }

    close $_fh or die "Could not close file $_filename\n";

    return;
}

#------------------------------------------------------------------
sub write_har_file {
    my ($_proxy_port) = @_;

    if (not defined $_proxy_port) {
        return;
    }

    # get the har file from browsermob-proxy
    require LWP::Simple;
    my $_url = "http://localhost:9091/proxy/$_proxy_port/har";
    $har_file_content = LWP::Simple::get $_url;

    require Encode;
    $har_file_content = Encode::encode_utf8( $har_file_content );

    # write har file uncompressed
    my $_filename = 'temp/' . $temp_folder_name . '/har.txt';
    open my $_fh, '>', $_filename or die "Could not open file '$_filename' $!\n";
    binmode $_fh; # set binary mode
    print {$_fh} $har_file_content;
    close $_fh or die "Could not close file $_filename\n";

    # write har file compressed
    require Compress::Zlib;
    $_filename = 'temp/' . $temp_folder_name . '/har.gzip';
    open my $_fh2, '>', $_filename or die "Could not open file '$_filename' $!\n";
    binmode $_fh2; # set binary mode
    my $_compressed = Compress::Zlib::memGzip($har_file_content);
    print {$_fh2} $_compressed;
    close $_fh2 or die "Could not close file $_filename\n";

    return;
}

#------------------------------------------------------------------
sub shutdown_proxy {
    my ($_proxy_port) = @_;

    require LWP::UserAgent;

    # prove that that the proxy port is in use
    #my $_available_port= _find_available_port($_proxy_port);
    #print "_available_port:$_available_port\n";

    if (defined $_proxy_port) {
        LWP::UserAgent->new->delete("http://localhost:9091/proxy/$_proxy_port");
    }

    # prove that that the proxy server has been shut down
    #$_available_port= _find_available_port($_proxy_port);
    #print "_proxy_port:$_proxy_port\n";
    #print "_available_port:$_available_port\n";

    return;
}

#------------------------------------------------------------------
sub shutdown_selenium_server {
    my ($_selenium_port) = @_;

    if (not defined $_selenium_port) {
        return;
    }

    require LWP::Simple;

    my $_url = "http://localhost:$_selenium_port/selenium-server/driver/?cmd=shutDownSeleniumServer";
    my $_content = LWP::Simple::get $_url;
    #print {*STDOUT} "Shutdown Server:$_content\n";

    return;
}

#------------------------------------------------------------------
sub start_selenium_server {
    my ($_testfile_contains_selenium) = @_;

    if (not defined $_testfile_contains_selenium) {
        return;
    }

    # copy chromedriver - source location hardcoded for now
    copy 'C:/selenium-server/chromedriver.exe', "temp/$temp_folder_name/chromedriver.eXe";

    # find free port
    my $_selenium_port = _find_available_port(9001);
    #print "_selenium_port:$_selenium_port\n";

    my $_abs_chromedriver_full = File::Spec->rel2abs( "temp\\$temp_folder_name\\chromedriver.eXe" );
    my $_abs_selenium_log_full = File::Spec->rel2abs( "temp\\$temp_folder_name\\selenium_log.txt" );

    my $_cmd = qq{wmic process call create 'cmd /c java -Dwebdriver.chrome.driver="$_abs_chromedriver_full" -Dwebdriver.chrome.logfile="$_abs_selenium_log_full" -jar C:\\selenium-server\\selenium-server-standalone-2.46.0.jar -port $_selenium_port -trustAllSSLCertificates'}; #
    my $_result = `$_cmd`;
    #print "_cmd:\n$_cmd\n";
    #print "start selenium result:\n$_result\n";

    return $_selenium_port;
}

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
sub start_browsermob_proxy {
    my ($_testfile_contains_selenium, $_opt_use_browsermob_proxy) = @_;

    if (not defined $_opt_use_browsermob_proxy) {
        return;
    }

    if (not $_opt_use_browsermob_proxy eq 'true') {
        return;
    }

    # for the moment, a proxy can only be used in conjunction with selenium
    if (not defined $_testfile_contains_selenium) {
        return;
    }

    my $_cmd = 'subs\start_browsermob_proxy.pl ' . $temp_folder_name;
    my $_proxy_port = `$_cmd`;
    return $_proxy_port;

}

#------------------------------------------------------------------
sub does_testfile_contain_selenium {
    my ($_testfile_full) = @_;

    my $_text = read_file($_testfile_full);

    if ($_text =~ m/\$driver->/) {
        return 'true';
    }

    return;
}

#------------------------------------------------------------------
sub get_webinject_location {

    my $_cmd = 'subs\get_webinject_location.pl';
    my $_result = `$_cmd`;

    return $_result;
}

#------------------------------------------------------------------
sub publish_static_files {
    my ($_opt_environment) = @_;

    my $_cmd = 'subs\publish_static_files.pl ' . $_opt_environment;
    my $_result = `$_cmd`;

    return;
}

#------------------------------------------------------------------
sub publish_results_on_web_server {
    my ($_opt_environment, $_opt_target, $_testfile_full, $_opt_batch, $_run_number) = @_;

    my $_cmd = 'subs\publish_results_on_web_server.pl ' . $_opt_environment . q{ } . $opt_target . q{ } . $_testfile_full . q{ } . $temp_folder_name . q{ } . $_opt_batch . q{ } . $_run_number;

    my $_result = `$_cmd`;

    return;
}

#------------------------------------------------------------------
sub write_final_result {
    my ($_opt_environment, $_opt_target, $_testfile_full, $_opt_batch, $_run_number) = @_;

    my $_cmd = 'subs\write_final_result.pl ' . $_opt_environment . q{ } . $opt_target . q{ } . $_testfile_full . q{ } . $temp_folder_name . q{ } . $_opt_batch . q{ } . $_run_number;

    my $_result = `$_cmd`;

    return;
}

#------------------------------------------------------------------
sub write_pending_result {
    my ($_opt_environment, $_opt_target, $_testfile_full, $_opt_batch, $_run_number) = @_;

    my $_cmd = 'subs\write_pending_result.pl ' . $_opt_environment . q{ } . $opt_target . q{ } . $_testfile_full . q{ } . $temp_folder_name . q{ } . $_opt_batch . q{ } . $_run_number;
    my $_result = `$_cmd`;

    return;
}

#------------------------------------------------------------------
sub check_testfile_xml_parses_ok {

    my $_xml = read_file($testfile_full);

    # for convenience, WebInject allows ampersand and less than to appear in xml data, so this needs to be masked
    $_xml =~ s/&/{AMPERSAND}/g;
    $_xml =~ s/\\</{LESSTHAN}/g;

    # here we parse the xml file in an eval, and capture any error returned (in $@)
    my $_message;
    my $_result = eval { XMLin($_xml) };

    if ($@) {
        $_message = $@;
        $_message =~ s{ at C:.*}{}g; # remove misleading reference Parser.pm
        $_message =~ s{\n}{}g; # remove line feeds
        die "\n".$_message." in $testfile_full\n";
    }

    return;
}

#------------------------------------------------------------------
sub get_run_number {
    my ($_opt_environment, $_testfile_full) = @_;

    my $_cmd = 'subs\get_run_number.pl ' . $_opt_environment . q{ } . $_testfile_full . q{ } . $temp_folder_name;
    my $_run_number = `$_cmd`;
    #print {*STDOUT} "run_number [$_run_number]\n";

    return $_run_number;
}

#------------------------------------------------------------------
sub create_webinject_config_file {

    if (not -e 'environment_config/' . $opt_environment . '.config') {
        die "Could not find environment_config/$opt_environment.config\n";
    }

    if (not -e 'environment_config/' . $opt_environment) {
        die "Could not find folder environment_config/$opt_environment\n";
    }

    # if $opt_target contains an alias, change it to the real value
    my $_alias = Config::Tiny->new;
    if (-e "environment_config/$opt_environment/_alias.config") {
        $_alias = Config::Tiny->read( "environment_config/$opt_environment/_alias.config" );

        if (defined $_alias->{_}->{$opt_target}) {
            $opt_target = $_alias->{_}->{$opt_target};
        }
    }

    if (not -e "environment_config/$opt_environment/$opt_target.config") {
        die "Could not find environment_config/$opt_environment/$opt_target.config\n";
    }

    $target_config = Config::Tiny->read( "environment_config/$opt_environment/$opt_target.config" );

    $environment_config = Config::Tiny->read( "environment_config/$opt_environment.config" );
    
    if (-e "environment_config/_global.config") {
        $global_config = Config::Tiny->read( 'environment_config/_global.config' );
    }

    my $_config_file_full = "temp/$temp_folder_name/$opt_target.xml"; 
    open $WEBINJECT_CONFIG, '>' ,"$_config_file_full" or die "\nERROR: Failed to open $_config_file_full for writing\n\n";
    print {$WEBINJECT_CONFIG} "<root>\n";
    _write_webinject_config('main');
    _write_webinject_config('userdefined');
    _write_webinject_config('autoassertions');
    _write_webinject_config('smartassertions');
    print {$WEBINJECT_CONFIG} "</root>\n";
    close $WEBINJECT_CONFIG or die "\nCould not close $_config_file_full\n\n";

    my ($_config_file_name, $_config_file_path) = fileparse($_config_file_full,'.xml');

    return $_config_file_full, $_config_file_name, $_config_file_path;
}

#------------------------------------------------------------------
sub _write_webinject_config {
    my ($_section) = @_;

    # config parameters defined under [main] will be written at the root level of the WebInject config
    my $_indent = q{};
    if (not $_section eq 'main') {
        $_indent = q{    };
        print {$WEBINJECT_CONFIG} "    <$_section>\n";
    }

    foreach my $_parameter (sort keys %{$target_config->{$_section}}) {
        print {$WEBINJECT_CONFIG} "    $_indent<$_parameter>";
        print {$WEBINJECT_CONFIG} "$target_config->{$_section}->{$_parameter}";
        print {$WEBINJECT_CONFIG} "</$_parameter>\n";
    }

    foreach my $_parameter (sort keys %{$environment_config->{$_section}}) {
        if ( $target_config->{$_section}->{$_parameter} ) {
            # _target_config takes priority - parameter has already been written
            next;
        }

        print {$WEBINJECT_CONFIG} "    $_indent<$_parameter>";
        print {$WEBINJECT_CONFIG} "$environment_config->{$_section}->{$_parameter}";
        print {$WEBINJECT_CONFIG} "</$_parameter>\n";
    }

    foreach my $_parameter (sort keys %{$global_config->{$_section}}) {
        if ( $target_config->{$_section}->{$_parameter} ) {
            # _target_config takes priority - parameter has already been written
            next;
        }

        if ( $environment_config->{$_section}->{$_parameter} ) {
            # _environment_config takes priority - parameter has already been written
            next;
        }

        print {$WEBINJECT_CONFIG} "    $_indent<$_parameter>";
        print {$WEBINJECT_CONFIG} "$global_config->{$_section}->{$_parameter}";
        print {$WEBINJECT_CONFIG} "</$_parameter>\n";
    }

    if (not $_section eq 'main') {
        print {$WEBINJECT_CONFIG} "    </$_section>\n";
    }
    
    return;
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
    mkdir 'temp/' . $_random_folder or die "\n\nCould not create temporary folder temp/$_random_folder\n";

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

    if (-e "temp/$_remove_folder") {
        unlink glob 'temp/' . $_remove_folder . q{/*} or die "Could not delete temporary files in folder temp/$_remove_folder\n";
    }

    my $_max = 30;
    my $_try = 0;

    ATTEMPT:
    {
        eval
        {
            rmdir 'temp/' . $_remove_folder or die "Could not remove temporary folder temp/$_remove_folder\n";
        };

        if ( $@ and $_try++ < $_max )
        {
            #print "\nError: $@ Failed to remove folder, trying again...\n";
            sleep 0.1;
            redo ATTEMPT;
        }
    }

    if ($@) {
        print "\nError: $@ Failed to remove folder temp/$_remove_folder after $_max tries\n\n";
    }

    return;
}

#------------------------------------------------------------------
sub _read_config {
    $config = Config::Tiny->read( 'wif.config' );

    $opt_target = $config->{main}->{target};
    $opt_batch = $config->{main}->{batch};
    $opt_environment = $config->{main}->{environment};
    $testfile_full = $config->{main}->{testfile_full};
    $selenium_location_full = $config->{main}->{selenium_location_full};
    $opt_use_browsermob_proxy = $config->{main}->{use_browsermob_proxy};
    $web_server_location_full = $config->{main}->{web_server_location_full};
    $config_is_automation_controller = $config->{main}->{is_automation_controller};

    # normalise config
    if (lc $config_is_automation_controller eq 'true' ) {
        $config_is_automation_controller = 'true';
    } else {
        $config_is_automation_controller = 'false';
    }

    # normalise config
    if (lc $opt_use_browsermob_proxy eq 'true' ) {
        $opt_use_browsermob_proxy = 'true';
    } else {
        $opt_use_browsermob_proxy = 'false';
    }

    return;
}

#------------------------------------------------------------------
sub _write_config {

    if (defined $opt_no_update_config) {
        return;
    }

    my $_config = Config::Tiny->new;

    $config->{main}->{target} = $opt_target;
    $config->{main}->{batch} = $opt_batch;
    $config->{main}->{environment} = $opt_environment;
    $config->{main}->{testfile_full} = $testfile_full;
    $config->{main}->{selenium_location_full} = $selenium_location_full;
    $config->{main}->{use_browsermob_proxy} = $opt_use_browsermob_proxy;
    $config->{main}->{web_server_location_full} = $web_server_location_full;
    $config->{main}->{is_automation_controller} = $config_is_automation_controller;

    $config->write( 'wif.config' );

    return;
}

#------------------------------------------------------------------
sub get_options_and_config {  #shell options

    _read_config();

    # config file definition wins over hard coded defaults
    if (not defined $opt_environment) { $opt_environment = 'DEV'; }; # default the environment name
    if (not defined $opt_batch) { $opt_batch = 'Default_Batch'; }; # default the batch

    my $_opt_no_update_config;
    # options specified at the command line win over those defined in wif.config
    Getopt::Long::Configure('bundling');
    GetOptions(
        't|target=s'                => \$opt_target,
        'b|batch=s'                 => \$opt_batch,
        'e|env=s'                   => \$opt_environment,
        'p|use-browsermob-proxy=s'  => \$opt_use_browsermob_proxy,
        'n|no-retry'                => \$opt_no_retry,
        'u|no-update-config'        => \$opt_no_update_config,
        'k|keep'                    => \$opt_keep,
        'v|V|version'               => \$opt_version,
        'h|help'                    => \$opt_help,
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
        exit;
    }

    # read the testfile name, and ensure it exists
    if (($#ARGV + 1) < 1) {
        if (not defined $testfile_full) {
            print "\nERROR: No test file name specified at command line or found in wif.config\n";
            print_usage();
            exit;
        }
    } else {
        $testfile_full = $ARGV[0];
    }
    ($testfile_name, $testfile_path) = fileparse($testfile_full,'.xml');

    if (not -e $testfile_full) {
        die "\n\nERROR: no such test file found $testfile_full\n";
    }

    if (not defined $opt_target) {
        print "\n\nERROR: Target sub environment name must be specified\n";
        exit;
    }

    # now we know what the preferred settings are, save them for next time
    _write_config();

    return;
}

sub print_version {
    print "\nWebInjectFramework version $VERSION\nFor more info: https://github.com/Qarj/WebInjectFramework\n\n";
    return;
}

sub print_usage {
    print <<'EOB'

Usage: wif.pl tests\testfilename.xml <<options>>

-t|--target                 target environment handle           --target skynet
-b|--batch                  batch name for grouping results     --batch SmokeTests
-e|--env                    high level environment DEV, LIVE    --env UAT
-p|--use-browesermob-proxy  use browsermob-proxy
-n|--no-retry               do not invoke retries
-u|--no-update-config       do not update config to reflect options
-k|--keep                   keep temporary files

wif.pl -v|--version
wif.pl -h|--help
EOB
;
return;
}
#------------------------------------------------------------------
