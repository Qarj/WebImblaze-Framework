#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

use v5.22;
use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '0.0.1';

use Storable 'dclone';
use File::Basename;
use File::Spec;
use File::Slurp;
use XML::Simple;
use File::Copy qw(copy), qw(move);
use File::Path qw(make_path remove_tree);
use Data::Dumper;

local $| = 1;    #don't buffer output to STDOUT

my %case;

my $SPACES = 24;

my ( $xml_test_cases, $testnum, $stdout );

my $previous_testnum = 0;

our $this_script_folder_full = dirname(__FILE__);

read_xml_test_steps( get_test_file_name() );

transmute_to_lean_format();

print $stdout;

#------------------------------------------------------------------
sub get_test_file_name {

    if ( ( $#ARGV + 1 ) > 1 ) {
        die "\nERROR: Too many arguments\n\n";
    }

    if ( ( $#ARGV + 1 ) < 1 ) {
        die "\nERROR: Not enough arguments\n\n";
    }

    return $ARGV[0];
}

#------------------------------------------------------------------
sub read_xml_test_steps {
    my ($_source_file_name) = @_;

    my $_test_steps = read_file($_source_file_name);

    if ( $_test_steps =~ /[^<]*<testcases/s ) {

        #        say 'Classic WebInject xml style format detected';
    }
    else {
        die 'Unrecognised file format';
    }

    # for convenience, WebInject allows ampersand and less than to appear in xml data, so this needs to be masked
    $_test_steps =~ s/&/{AMPERSAND}/g;
    while ( $_test_steps =~ s/\w\s*=\s*"[^"]*\K<(?!case)([^"]*")/{LESSTHAN}$1/sg ) { }
    while ( $_test_steps =~ s/\w\s*=\s*'[^']*\K<(?!case)([^']*')/{LESSTHAN}$1/sg ) { }

    my $_case_count = 0;
    while ( $_test_steps =~ /<case/g ) {    #count test cases based on '<case' tag
        $_case_count++;
    }

    if ( $_case_count == 1 ) {
        $_test_steps =~ s/<\/testcases>/<case id="99999999" description1="dummy test case"\/><\/testcases>/
          ;                                 #add dummy test case to end of file
    }

    # here we parse the xml file in an eval, and capture any error returned (in $@)
    $xml_test_cases = eval { XMLin( $_test_steps, VarAttr => 'varname' ) };

    #$stdout .= Data::Dumper::Dumper($xml_test_cases);

    return;
}

sub transmute_to_lean_format {

    my @_test_steps = sort { $a <=> $b } keys %{ $xml_test_cases->{case} };
    my $_numsteps   = scalar @_test_steps;

    my $_step_index;
    ## Loop over each of the test cases (test steps) with C Style for loop (due to need to update $step_index in a non standard fashion)
  TESTCASE:
    for ( $_step_index = 0 ; $_step_index < $_numsteps ; $_step_index++ ) {
        $testnum = $_test_steps[$_step_index];

        #$stdout .= $testnum."\n";

        $stdout .= output_includes_less_than_testnum();

        get_case();
        rename_selenium_shell();
        rename_parameter( 'parseresponseREDIRECTURL', 'parseresponseREDIRECT' );
        rename_value( '{REDIRECTURL}', '{REDIRECT}' );
        rename_parameter( 'description1', 'step' );
        rename_parameter( 'description2', 'desc' );

        $stdout .= output_parameter('step');
        $stdout .= output_parameter('desc');
        $stdout .= output_parameter('section');
        $stdout .= output_multi('var');
        $stdout .= output_parameter('url');
        $stdout .= output_parameter('posttype');
        $stdout .= output_parameter('postbody');
        $stdout .= output_parameter('setcookie');
        $stdout .= output_multi('selenium');
        $stdout .= output_multi('shell');
        $stdout .= output_parameter('verifytext');
        $stdout .= output_multi('assertcount');
        $stdout .= output_multi('verifypositive');
        $stdout .= output_multi('verifynegative');
        $stdout .= output_parameter('verifyresponsetime');
        $stdout .= output_multi('parseresponse');

        my $_last = output_parameter('runon');
        $_last   .= output_parameter('runif');
        $_last   .= output_parameter('abort');

        $stdout .= output_remaining_parms();

        $stdout .= $_last;
        $stdout .= "\n";
    }

    $stdout .= output_includes_more_than_testnum();

    return;
}

sub output_includes_less_than_testnum {
    my @_include_steps = sort { $a <=> $b } keys %{ $xml_test_cases->{include} };
    my $_numincludes   = scalar @_include_steps;

    my $_out = q{};

    my $_include_index;
    for ( $_include_index = 0 ; $_include_index < $_numincludes ; $_include_index++ )
    {    ## no critic(ProhibitCStyleForLoops)
        my $_includenum = $_include_steps[$_include_index];

        if ( $_includenum < $previous_testnum ) {
            next;
        }

        if ( $_includenum > $testnum ) {
            next;
        }

        $_out .= sprintf( '%-' . $SPACES . 's', 'include: ' );
        $_out .= $xml_test_cases->{include}->{$_includenum}->{file} . "\n\n";

    }

    $previous_testnum = $testnum;

    return $_out;
}

sub output_includes_more_than_testnum {
    my @_include_steps = sort { $a <=> $b } keys %{ $xml_test_cases->{include} };
    my $_numincludes   = scalar @_include_steps;

    my $_out = q{};

    my $_include_index;
    for ( $_include_index = 0 ; $_include_index < $_numincludes ; $_include_index++ )
    {    ## no critic(ProhibitCStyleForLoops)
        my $_includenum = $_include_steps[$_include_index];

        if ( $_includenum < $testnum ) {
            next;
        }

        $_out .= sprintf( '%-' . $SPACES . 's', 'include: ' );
        $_out .= $xml_test_cases->{include}->{$_includenum}->{file} . "\n\n";

    }

    return $_out;
}

sub get_case {

    undef %case;    ## do not allow values from previous test cases to bleed over

    foreach my $_case_attribute ( keys %{ $xml_test_cases->{case}->{$testnum} } ) {
        $case{$_case_attribute} = $xml_test_cases->{case}->{$testnum}->{$_case_attribute};
    }

    foreach my $_case_attribute ( keys %case ) {
        $case{$_case_attribute} = $xml_test_cases->{case}->{$testnum}->{$_case_attribute};
        convert_back_xml( $case{$_case_attribute} );
    }

    return;
}

## no critic (RequireArgUnpacking)
sub convert_back_xml {

    $_[0] =~ s/{AMPERSAND}/&/g;
    $_[0] =~ s/{LESSTHAN}/</g;

    return;
}

sub rename_selenium_shell {

    my $_old_name = 'command';
    my $_new_name = q{};

    if ( $case{method} eq 'selenium' ) {
        $_new_name = 'selenium';
    }

    if ( $case{method} eq 'cmd' ) {
        $_new_name = 'shell';
    }

    delete $case{method};

    if ( not $_new_name ) {
        return;
    }

    foreach my $_case_parameter ( sort keys %case ) {

        if ( ( substr $_case_parameter, 0, length($_old_name) ) eq $_old_name ) {
            my $_suffix        = substr $_case_parameter, length($_old_name);
            my $_full_new_name = $_new_name . $_suffix;
            $case{$_full_new_name} = $case{$_case_parameter};
            delete $case{$_case_parameter};
        }

    }

    return;
}

sub rename_parameter {
    my ( $_parameter, $_new_parameter_name ) = @_;

    foreach my $_case_parameter ( sort keys %case ) {
        if ( $_case_parameter eq $_parameter ) {
            $case{$_new_parameter_name} = $case{$_case_parameter};
            delete $case{$_case_parameter};
        }
    }

    return;
}

sub rename_value {
    my ( $_value, $_new_value ) = @_;

    $_value = quotemeta($_value);

    foreach my $_case_parameter ( sort keys %case ) {
        $case{$_case_parameter} =~ s/$_value/$_new_value/g;
    }

    return;
}

sub output_multi {
    my ($_parameter) = @_;

    my $_out = q{};

    $_out .= output_parameter($_parameter);

    for ( my $_i = 0 ; $_i <= 99 ; $_i++ ) {
        $_out .= output_parameter( $_parameter . $_i );
    }

    foreach my $_case_parameter ( sort keys %case ) {
        if ( ( substr $_case_parameter, 0, length($_parameter) ) eq $_parameter ) {
            $_out .= output_parameter($_case_parameter);
        }
    }

    return $_out;
}

sub output_parameter {
    my ($_parameter) = @_;

    if ( not defined $case{$_parameter} ) {
        return q{};
    }

    my $_out = sprintf( '%-' . $SPACES . 's', $_parameter . ': ' );
    $_out .= $case{$_parameter} . "\n";
    delete $case{$_parameter};

    return $_out;
}

sub output_remaining_parms {

    foreach my $_case_parameter ( sort keys %case ) {
        $stdout .= output_parameter($_case_parameter);
    }

    return;
}

## References
##
## http://www.kichwa.com/quik_ref/spec_variables.html