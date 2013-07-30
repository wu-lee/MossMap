#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../ll/lib/perl5";
use lib "$Bin/../lib";


{
    # Stub the model
    package MossMap::Model;
    use strict;
    use warnings;
    use Carp qw(croak);

    # Prevent the original from being loaded later.
    $INC{'MossMap/Model.pm'} = __FILE__;

    my @sets;

    sub new { return bless {}, shift }

    sub data_sets {
        return [grep { defined } @sets];
    }

    sub new_data_set {
        my ($self, $data) = @_;
        $data->{id} = @sets;
        
        push @sets, $data;
        return $data->{id};
    }

    sub delete_data_set {
        my ($self, $id) = @_;
        delete $sets[$id];
        return;
    }

    sub get_data_set {
        my ($self, $id) = @_;
        my $data = $sets[$id];
        
        return $data;
    }

    sub set_data_set {
        my ($self, $data) = @_;
        croak "argument must be a hashref"
            unless ref $data eq 'HASH';
        my $id = $data->{id};
        croak "argument must have an id defined"
            unless defined $id;
        
        $sets[$id] = $data;
        return;
    }
}


use Test::More;
use Test::Mojo;
require "$Bin/../moss-map.pl";

my $t = Test::Mojo->new;

# Don't hide internal exceptions, show them on STDERR
$t->app->hook(around_dispatch => sub {
                  my ($next, $c) = @_;
                  return if eval { $next->(); 1 };
                  warn $@;
                  die $@;
              });

#print {$t->app->log->handle} "hello\n";


# Check our database is empty
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->json_is([],'data_sets is empty');
 

$t
    ->get_ok('/unauthorized')
    ->status_is(401, "/unauthorized url is 401");
$t
    ->post_ok('/unauthorized')
    ->status_is(401, "/unauthorized url is 401");



# Check authentication works
$t
    ->post_ok('/data/sets')
    ->status_is(401)
    ->json_is({error => 'Unauthorized'},'Unauthorized error result');

$t
    ->post_ok('/login.json', json => {user => 'nonesuch', password => 'secret'})
    ->status_is(401)
    ->json_is({error => 'Login failed'}, 'Login failed');

$t
    ->post_ok('/login.json', json => {user => 'user1', password => 'secret'})
    ->status_is(200)
    ->json_is({message => 'ok'}, 'Login ok');


# Invalid item id 0
$t
    ->get_ok('/data/set/0')
    ->status_is(404)
    ->json_is({id => 0, error => 'Invalid id'}, 'Data set 0 is absent');

$t
    ->post_ok('/data/sets', json => {name => 'set1'})
    ->status_is(201)
    ->json_is({message => 'ok', id => 0}, 'Posted set ok');


# Check our mock database is no-longer empty
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->json_is([{id => 0, name => 'set1'}],'data_sets has new member');
 
# Get the item we just obtained
$t
    ->get_ok('/data/set/0')
    ->status_is(200)
    ->json_is({id => 0, name => 'set1'},'Data set 0 is correct');
 

# Put a new value for 0
$t
    ->put_ok('/data/set/0', json => {name => 'set1.1'})
    ->status_is(200)
    ->json_is({message => 'ok', id => 0}, 'Put set update ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->json_is([{id => 0, name => 'set1.1'}],'Data sets correct');


# Make sure id is ignored FIXME or should it be an error?
$t
    ->put_ok('/data/set/0', json => {name => 'set1.2', id => 3})
    ->status_is(200)
    ->json_is({message => 'ok', id => 0}, 'Put set update with redundant id ignored ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->json_is([{id => 0, name => 'set1.2'}], 'Data sets correct');

# Put a new value for 1
$t
    ->put_ok('/data/set/3', json => {name => 'set3', id => 7})
    ->status_is(200)
    ->json_is({message => 'ok', id => 3}, 'Put create new set id 3 ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->json_is([{id => 0, name => 'set1.2'},
               {id => 3, name => 'set3'}], 'Data sets correct');

# Delete 1
$t
    ->delete_ok('/data/set/3')
    ->status_is(200)
    ->json_is({message => 'ok', id => 3}, 'Delete set id 3 ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->json_is([{id => 0, name => 'set1.2'}], 'Data sets correct');

# FIXME edge cases... logout?
# FIXME multi-set post? delete?
# FIXME set data

done_testing;
