# $Id$
# $Revision$
# $Date$

package Alerter;

use strict;
use warnings;
use vars qw/ $VERSION /;

$VERSION = '1.0.0';

use LWP;
local $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 'false';
use IO::Socket::SSL qw( SSL_VERIFY_NONE );
use HTTP::Request::Common;
use HTTP::Cookies;

#------------------------------------------------------------------
sub slack_alert {
    my ( $_message, $_hook ) = @_;

    my $_useragent  = LWP::UserAgent->new( keep_alive => 1 );
    my $_cookie_jar = HTTP::Cookies->new;
    $_useragent->agent('http poster');

    my $_post_type = 'application/json';
    my $_post_body = '{"text": "' . $_message . '", "username": "Regression-Test-Failures"}';
    print "$_post_body\n";
    my $_url = $_hook;

    my $_request = HTTP::Request->new( 'POST', "$_url" );
    $_request->content_type("$_post_type");
    $_request->content("$_post_body");

    my $_response        = $_useragent->request($_request);
    my $_string_response = $_response->as_string;
    if ( $_string_response =~ m/\Rok/ ) {
        print "\nAlert sent to Slack ok.\n";
    }
    else {
        print "\nFailed to send alert to Slack.\n";
    }

    $_cookie_jar->extract_cookies($_response);

    return;
}

1;
