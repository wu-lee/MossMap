#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use lib "$Bin/../ll/lib/perl5";
use lib "$Bin/../lib";
use lib "$Bin/lib";

require "$Bin/../moss-map.pl";

use MyTest::Mojo;
my $t = MyTest::Mojo->new;


# Check our database is empty

=pod

$t
    ->get_ok('/session')
    ->status_is(200)
    ->content_is("Not logged in",
                 '/session -> "Not logged in"');
 
$t
    ->post_ok('/session/login',
              form => { username => 'user1',
                        password => 'secret' })
    ->status_is(200);

$t
    ->get_ok('/session')
    ->status_is(200)
    ->content_is("Logged in as 'user1'",
                 '/session -> "Logged in as user1"');
 
$t
    ->post_ok('/session/logout')
    ->status_is(200)
    ->content_is("Logged out 'user1'",
                 '/session/logout -> "Logged out user1"');

=cut

$t
    ->get_ok('/session')
    ->status_is(200)
    ->json_is({},
              '/session -> {}');

$t
    ->post_ok('/session/login',
              json => { username => 'user1',
                        password => 'whoops' })
    ->status_is(401)
    ->json_is({error => 'authentication failed',
               username => 'user1'},
              '/session/login + bad password failed');

$t
    ->post_ok('/session/login',
              json => { username => 'user2',
                        password => 'secret' })
    ->status_is(401)
    ->json_is({error => 'authentication failed',
               username => 'user2'},
              '/session/login + bad user failed');

$t
    ->post_ok('/session/login',
              json => { username => 'user1',
                        password => 'secret' })
    ->status_is(200)
    ->json_is({message => 'logged in',
               username => 'user1'},
              '/session/login + correct credentials succeeds');


$t
    ->get_ok('/session')
    ->status_is(200)
    ->json_is({username => 'user1'},
              '/session reflects log-in');
 
$t
    ->post_ok('/session/logout')
    ->status_is(200)
    ->json_is({message => 'logged out',
               username => 'user1'},
              '/session log-out ok');
    
$t
    ->post_ok('/session/logout')
    ->status_is(200)
    ->json_is({message => 'logged out'},
              '/session log-out ok, without having been logged in');
    
 
$t
    ->get_ok('/session')
    ->status_is(200)
    ->json_is({},
              '/session -> {}');

done_testing;
