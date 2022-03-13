#!/usr/bin/perl

# $Id$
# $Revision$
# $Date$

package BatchSummary;

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '1.0.0';

use XML::Twig;

my $start_time;
my $end_time;
my $number_of_pending_items;
my $number_of_items;
my $items_text;
my $number_of_execution_abortions;
my $number_of_failures;
my $number_of_failed_runs;
my $total_run_time_seconds;
my $elapsed_seconds;
my $elapsed_minutes;
my $total_steps_run;
my ( $status, $status_message );
my $dd;
my $mm;

sub _calculate_stats() {
    my ($_twig) = @_;

    my $_root = $_twig->root;

    $start_time = _get_earliest_start_time($_root);
    $end_time   = _get_largest_end_time($_root);

    $number_of_pending_items = _get_number_of_pending_items($_root);

    # calculate the number of items in the batch - pending items are not counted
    $number_of_items = $_root->children_count() - $number_of_pending_items;

    # $items_text will look like [1 item] or [5 items] or [4 items/1 pending]
    $items_text = _build_items_text( $number_of_items, $number_of_pending_items );

    $number_of_execution_abortions = _get_number_of_execution_abortions($_root);

    $number_of_failures    = _get_number_of_failures($_root);
    $number_of_failed_runs = _get_number_of_failed_runs($_root);

    $total_run_time_seconds = _get_total_run_time_seconds($_root);

    my $_start_time_seconds = _get_start_time_seconds($_root);
    my $_end_time_seconds   = _get_end_time_seconds($_root);

    $elapsed_seconds = $_end_time_seconds - $_start_time_seconds;
    $elapsed_minutes = sprintf '%.1f', ( $elapsed_seconds / 60 );

    $total_steps_run = _get_total_steps_run($_root);

    ( $status, $status_message ) = _get_status($_root);

    ( $dd, $mm ) = _get_day_month($_root);

    return;
}

sub _build_items_text {
    my ( $_number_of_items, $_number_of_pending_items ) = @_;

    # singular or plural
    my $_items_word;
    if ( $_number_of_items == 1 ) {
        $_items_word = 'item';
    }
    else {
        $_items_word = 'items';
    }

    # if there are some pending items, we need a different text
    my $_items_text;
    if ( $_number_of_pending_items == 0 ) {
        $_items_text = "[$_number_of_items $_items_word]";
    }
    else {
        $_items_text = "[$_number_of_items $_items_word/$_number_of_pending_items pending]";
    }

    return $_items_text;
}

#------------------------------------------------------------------
sub _get_status {
    my ($_root) = @_;

    # example tags: <status>CORRUPT</status>
    #               <status-message>Not well formed at line 582</status-message>

    # for the moment, status-message is only set when status is corrupt
    my $_status = 'NORMAL';
    my $_status_message;
    my $_elt = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'status_message' ) ) {
        if ( $_elt->field() ) {
            $_status_message = $_elt->field();
            $_status         = 'CORRUPT';
        }
    }

    return $_status, $_status_message;
}

#------------------------------------------------------------------
sub _get_total_steps_run {
    my ($_root) = @_;

    # example tag: <testcasesrun>2</testcasesrun>

    my $_total_run = 0;
    my $_elt       = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'test_steps_run' ) ) {
        $_total_run += $_elt->field();
    }

    return $_total_run;
}

#------------------------------------------------------------------
sub _get_end_time_seconds {
    my ($_root) = @_;

    # example tag: <endseconds>75089</endseconds>

    my $_end_seconds = 0;
    my $_elt         = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'end_seconds' ) ) {
        if ( $_elt->field() > $_end_seconds ) {
            $_end_seconds = $_elt->field();
        }
    }

    return $_end_seconds;
}

#------------------------------------------------------------------
sub _get_start_time_seconds {
    my ($_root) = @_;

    # example tag: <startseconds>75059</startseconds>

    # there are 86400 seconds in a day, we need to find the smallest start time in seconds
    my $_start_seconds = 86_400;
    my $_elt           = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'start_seconds' ) ) {
        if ( $_elt->field() < $_start_seconds ) {
            $_start_seconds = $_elt->field();
        }
    }

    return $_start_seconds;
}

#------------------------------------------------------------------
sub _get_total_run_time_seconds {
    my ($_root) = @_;

    # example tag: <totalruntime>0.537</totalruntime>

    my $_elt            = $_root;
    my $_total_run_time = 0;
    while ( $_elt = $_elt->next_elt( $_root, 'total_run_time' ) ) {
        $_total_run_time += $_elt->field();
    }

    # format to 0 decimal places
    return sprintf '%.0f', $_total_run_time;
}

#------------------------------------------------------------------
sub _get_number_of_failed_runs {
    my ($_root) = @_;

    # assume we do not have any execution abortions
    my $_num_failed_runs = 0;

    my $_elt = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'test_steps_failed' ) ) {
        if ( $_elt->field() > 0 ) {
            $_num_failed_runs += 1;
        }
    }

    return $_num_failed_runs;
}

#------------------------------------------------------------------
sub _get_number_of_failures {
    my ($_root) = @_;

    # assume we do not have any execution abortions
    my $_num_failures = 0;

    my $_elt = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'test_steps_failed' ) ) {
        $_num_failures += $_elt->field();
    }

    return $_num_failures;
}

#------------------------------------------------------------------
sub _get_number_of_execution_abortions {
    my ($_root) = @_;

    # assume we do not have any execution abortions
    my $_num_failures = 0;

    my $_elt = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'execution_aborted' ) ) {
        if ( $_elt->field() eq 'true' ) {
            $_num_failures += 1;
        }
    }

    return $_num_failures;
}

#------------------------------------------------------------------
sub _get_number_of_pending_items {
    my ($_root) = @_;

    # assume we do not have any pending items
    my $_num_pending = 0;

    my $_elt = $_root;
    while ( $_elt = $_elt->next_elt( $_root, 'end_time' ) ) {
        if ( $_elt->field() eq 'PENDING' ) {
            $_num_pending += 1;
        }
    }

    return $_num_pending;
}

#------------------------------------------------------------------
sub _get_earliest_start_time {
    my ($_root) = @_;

    # example tag: <startdatetime>2016-04-05T20:50:59</startdatetime>
    # the very first run in the batch will always contain the earliest start time

    my $_start_time = $_root->first_child('run')->first_child_text('start_date_time');

    # just return the time portion of the date time string
    return substr $_start_time, 11;
}

sub _get_day_month {
    my ($_root) = @_;

    my $_dd = $_root->first_child('run')->first_child_text('dd');
    my $_mm = $_root->first_child('run')->first_child_text('mm');

    return $_dd, $_mm;
}

#------------------------------------------------------------------
sub _get_largest_end_time {
    my ($_root) = @_;

    # example tag: <end_time>2016-04-05T20:51:00</end_time>
    # we do not know which run in the batch ended last, so we have to examine all of them

    my $_elt      = $_root;
    my $_end_time = $_root->last_child('run')->last_child_text('end_time');
    while ( $_elt = $_elt->next_elt( $_root, 'end_time' ) ) {

        #cmp comparison operator -1 if string smaller, 0 if the same, 1 if first string greater than second
        if ( ( $_elt->field() cmp $_end_time ) == 1 ) {
            $_end_time = $_elt->field();
        }
    }

    if ( length $_end_time < 11 ) {

        # there is not an end time, batch is still pending
        return q{};
    }

    # just return the time portion of the date time string
    return substr $_end_time, 11;
}

sub _build_overall_summary_text {
    my ( $_opt_batch, $_opt_target, $_dd, $_mm ) = @_;

    if ( not $_dd ) {
        $_dd = $dd;
        $_mm = $mm;
    }

    my $_summary_text = q{};

    my $_overall = 'PASS';
    if ( $number_of_pending_items > 0 ) { $_overall = 'PEND'; }
    if ( $number_of_failures > 0 )      { $_overall = 'FAIL'; }
    if ( $number_of_execution_abortions > 0 ) {
        $_overall = 'EXECUTION ABORTED';
    }
    if ( $status eq 'CORRUPT' ) { $_overall = 'CORRUPT'; }

    if ( $status eq 'CORRUPT' ) {
        $_summary_text .=
          qq|$_overall $_dd/$_mm $start_time  - $end_time $items_text $_opt_batch: $status_message *$_opt_target*|;
    }
    elsif ( $number_of_execution_abortions > 0 ) {
        $_summary_text .=
qq|$_overall $_dd/$_mm $start_time  - $end_time $items_text $_opt_batch: $number_of_execution_abortions EXECUTION ABORTION(s), $number_of_failed_runs/$number_of_items items FAILED ($number_of_failures/$total_steps_run steps), $elapsed_minutes mins *$_opt_target*|;
    }
    else {
        if ( $number_of_failures > 0 ) {
            $_summary_text .=
qq|$_overall $_dd/$_mm $start_time  - $end_time $items_text $_opt_batch: $number_of_failed_runs/$number_of_items items FAILED ($number_of_failures/$total_steps_run steps), $elapsed_minutes mins *$_opt_target*|;
        }
        else {
            $_summary_text .=
qq|$_overall $_dd/$_mm $start_time  - $end_time $items_text $_opt_batch: ALL $total_steps_run steps OK, $elapsed_minutes mins *$_opt_target*|;
        }
    }

    return $_summary_text;
}

1;
