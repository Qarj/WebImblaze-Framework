#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

package Runner;

use strict;
use vars qw/ $VERSION /;

$VERSION = '1.5.0';

use Getopt::Long;
use Cwd;
use Config::Tiny;
use File::Spec;
use File::Basename;
use LWP;
use HTTP::Request::Common;
use IO::Socket::SSL;
local $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 'false';
local $| = 1; # don't buffer output to STDOUT

require Alerter;

my ($script_name, $script_path) = fileparse($0,'.pl');

my $config_wif_location = "../";
my $opt_batch = $script_name; # default the batch name to the script name
our ($opt_target, $opt_environment) = read_wif_config($config_wif_location.'wif.config');
my ($opt_check_alive, $opt_slack_alert);
my $opt_group;

my $failed_test_files_count = 0;
my $passed_test_files_count = 0;
my @failed_test_files;

sub start_runner {

    ($opt_target, $opt_batch, $opt_environment, $opt_check_alive, $opt_slack_alert, $opt_group) = get_options($opt_target, $opt_batch, $opt_environment, $opt_check_alive, $opt_slack_alert, $opt_group);
    $opt_target = lc $opt_target;
    $opt_environment = uc $opt_environment;
    
    if ($opt_check_alive) {
        if ( is_available($opt_check_alive) ) {
            # all systems go
        } else {
            # check-alive url returned no response, target server is down, do not run tests 
            exit;
        }
    }
    
    # add a random number to the batch name so this run will have a different name to a previous run
    $opt_batch .= random(99_999);
}

sub stop_runner {
    if ($failed_test_files_count && $opt_slack_alert) {
        my $_files = 'files';
        if ($failed_test_files_count == 1) { $_files = 'file'; }
        my $_message = "There were errors in $script_name. $failed_test_files_count test $_files returned an error status:\n";
        foreach (@failed_test_files) {
            $_message .= '    ['.$_.']'."\n";
        }
        print "\n".$_message;
        Alerter::slack_alert('<!channel> '.$_message, $opt_slack_alert);
        exit 1;
    } else {
        exit 0;
    }
}

sub start {
    my ($_test, $_groups, $_no_headless) = @_;

    if (not _group_match($_groups)) { return; }

    start_test($_test, $opt_target, $opt_batch, $opt_environment, $config_wif_location, $_no_headless);

    return;
}

sub call {
    my ($_test, $_groups, $_no_headless) = @_;
    
    if (not _group_match($_groups)) { return; }

    my $_status = Runner::call_test($_test, $opt_target, $opt_batch, $opt_environment, $config_wif_location, $_no_headless);

    my ($_test_name, undef) = fileparse($_test,'.xml');

    if ($_status) {
        $failed_test_files_count++;
        push @failed_test_files, $_test_name;
    } else {
        $passed_test_files_count++;
    }

    return;
}

sub _group_match {
    my ($_groups) = @_;

    if (not $_groups) {
        return 'true';
    }

    my $_group_match;
    if ($opt_group) {
        foreach my $_group ( @{$_groups} ) {
            if (lc $_group eq lc $opt_group) {
                $_group_match = 'true';
            }
        }
        if (not $_group_match) {
            return; # this test case file is not part of the specified group
        }
    }
    
    return 'true';
}

sub repeat {
    my ($_test, $_repeats) = @_;

    for my $_idx (1..$_repeats) {
        call($_test);
    }
}

sub start_test {
    my ($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location, $_no_headless) = @_;

    my @_args = _build_wif_args($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location, $_no_headless);

    # change dir to wif.pl location
    my $_orig_cwd = cwd;
    chdir $_config_wif_location;

    _start_windows_process('wif.pl '."@_args");

    chdir $_orig_cwd;

    return;
}

#------------------------------------------------------------------
sub call_test {
    my ($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location, $_no_headless) = @_;

    my @_args = _build_wif_args($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location, $_no_headless);

    # change dir to wif.pl location
    my $_orig_cwd = cwd;
    chdir $_config_wif_location;

    printf "%-69s ", $_test_file_full;
    print "...";

    my $_status = system('wif.pl '."@_args");
    if ($_status) {
        print " failed\n";
    } else {
        print " ok\n";
    }

    chdir $_orig_cwd;

    return $_status;
}

#------------------------------------------------------------------
sub _build_wif_args {
    my ($_test_file_full, $_config_target, $_config_batch, $_config_environment, $_config_wif_location, $_no_headless) = @_;

    my $_abs_test_file_full = File::Spec->rel2abs( $_test_file_full );

    my @_args;

    push @_args, $_abs_test_file_full;

    push @_args, '--target';
    push @_args, $_config_target;

    push @_args, '--batch';
    push @_args, $_config_batch;

    push @_args, '--env';
    push @_args, $_config_environment;

    push @_args, '--use-browsermob-proxy';
    push @_args, 'false';

    push @_args, '--no-update-config';

    push @_args, '--capture-stdout';

    if ($_no_headless eq 'no-headless') {
        # do not add headless argument
    } else {
        # push @_args, '--headless';
    }

    return @_args;
}

#------------------------------------------------------------------
sub _start_windows_process {
    my ($_command) = @_;

    my $_cwd = cwd;
    my $_wmic = "wmic process call create 'cmd /c cd /D $_cwd & $_command'"; #

    my $_result;
    $_result = `$_wmic`;
    #print "_wmic:$_wmic\n";
    #print "$_result\n";

    my $_pid;
    if ( $_result =~ m/ProcessId = (\d+)/ ) {
        $_pid = $1;
    }

    return $_pid;
}

#------------------------------------------------------------------
sub random {
    my ($_max) = @_;

    my $_random = int rand $_max;
    $_random = sprintf '%05d', $_random; # add some leading zeros

    return '_'.$_random;
}

#------------------------------------------------------------------
sub read_config {
    my ($_config_file_full) = @_;

    my $_config = Config::Tiny->read( $_config_file_full );

    # main
    my $_config_batch = $_config->{main}->{batch};

    # path
    my $_config_wif_location = $_config->{path}->{wif_location};

    return ($_config_batch, $_config_wif_location);
}

#------------------------------------------------------------------
sub read_wif_config {
    my ($_config_file_full) = @_;

    my $_config = Config::Tiny->read( $_config_file_full );

    # main
    my $_config_target = $_config->{main}->{target};
    my $_config_environment = $_config->{main}->{environment};

    return ($_config_target, $_config_environment);
}

#------------------------------------------------------------------
sub is_available {
    my ($_url) = @_;
    
    my $useragent = LWP::UserAgent->new(keep_alive=>1);
    
    $useragent->agent('WebGet');
    $useragent->timeout(20); # default timeout of 360 seconds
    
    $useragent->max_redirect('0');  #don't follow redirects for GET's (POST's already don't follow, by default)
    eval
    {
       $useragent->ssl_opts(verify_hostname=>0); ## stop SSL Certs from being validated - only works on newer versions of of LWP so in an eval
       $useragent->ssl_opts(SSL_verify_mode=>'SSL_VERIFY_NONE'); ## from Perl 5.16.3 need this to prevent ugly warnings
    };
    
    my $request = HTTP::Request->new('GET',"$_url");
    
    my $response = $useragent->request($request);
    
    #print $response->as_string;
    
    if (($response->as_string() =~ /HTTP\/1.(0|1) (1|2|3)/i)) {
        #print "\nRESPONSE CODE IS NORMAL\n";
    } else {
        $response->as_string() =~ /(HTTP\/1.)(.*)/i;
        if ($1) {  #this is true if an HTTP response returned
            #print "\nERROR RESPONSE CODE: ($1$2)\n";
        } else {
            print "\nERROR - NO RESPONSE, URL IS NOT REACHABLE\n";
            return; # return falsey
        }
    }
    
    return 'true';
}

#------------------------------------------------------------------
sub get_options {
    my ($_opt_target, $_opt_batch, $_opt_environment, $_opt_check_alive, $_opt_slack_alert, $_opt_group) = @_;

    my ($_opt_version, $_opt_help);

    Getopt::Long::Configure('bundling');
    GetOptions(
        't|target=s'                => \$_opt_target,
        'b|batch=s'                 => \$_opt_batch,
        'e|env=s'                   => \$_opt_environment,
        'g|group=s'                 => \$_opt_group,
        'c|check-alive=s'           => \$_opt_check_alive,
        's|slack-alert=s'           => \$_opt_slack_alert,
        'v|V|version'               => \$_opt_version,
        'h|help'                    => \$_opt_help,
        )
        or do {
            print_usage();
            exit;
        };

    if ($_opt_version) {
        print_version();
        exit;
    }

    if ($_opt_help) {
        print_version();
        print_usage();
        print "\nTarget         [$_opt_environment] $_opt_target\n";
        print "Batch          $_opt_batch\n";
        exit;
    }

    return $_opt_target, $_opt_batch, $_opt_environment, $_opt_check_alive, $_opt_slack_alert, $_opt_group;
}

sub print_version {
    print {*STDOUT} "\nRunner.pm version $VERSION\nFor more info: https://github.com/Qarj/WebInjectFramework\n";
    return;
}

sub print_usage {
    print <<'EOB'

Usage: <task_name>.pl tests\testfilename.xml <<options>>

-t|--target                 target "mini-environment"           --target skynet
-b|--batch                  batch name for grouping results     --batch Smoke

Smoke.pl -v|--version
Smoke.pl -h|--help
EOB
;
return;
}
#------------------------------------------------------------------

1;