#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use Test::More;
use lib "$Bin/../ll/lib/perl5";
use lib "$Bin/../lib";
use lib "$Bin/lib";

use MyTest::Data qw($temp_dir);

use MyTest::Mojo;
require "$Bin/../moss-map.pl";

my $t = MyTest::Mojo->new;

# Populate the (assumed empty) test database
$t->app->model->_schema->deploy;

# Don't hide internal exceptions, show them on STDERR
$t->app->hook(around_dispatch => sub {
                  my ($next, $c) = @_;
                  return if eval { $next->(); 1 };
                  warn $@;
                  die $@;
              });

my $records = [
    { id => 1, data_set_id => 1, grid_ref => 'sj1234', taxon => {id => 1, name => 'foo'}, recorder => {id => 1, name => 'alice'}, recorded_on => '2011-11-11'},
    { id => 2, data_set_id => 1, grid_ref => 'sj1234', taxon => {id => 2, name => 'goo'}, recorder => {id => 2, name => 'bob'}, recorded_on => '2012-12-12'},
];



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


# Invalid item id 1
$t
    ->get_ok('/data/set/1')
    ->status_is(404)
    ->json_is({id => 1, error => 'Invalid id'}, 'Data set 1 is absent');

$t
    ->post_ok('/data/sets', json => {name => 'set1', records => $records})
    ->status_is(201)
    ->json_is({message => 'ok', id => 1}, 'Posted set ok');

# Check our mock database is no-longer empty
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1',
                   created_on => 'whatever'}],
                 'Data set 1 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->data_sets),
    [{id => 1, name => 'set1',
      created_on => 'whatever',
      records => $records }],
    'Data sets are is correct';

# Get the item we just obtained
$t
    ->get_ok('/data/set/1')
    ->status_is(200)
    ->my_json_is({id => 1, name => 'set1',
                  created_on => 'whatever',
                  records => $records},
                 'Data set 1 is correct');

# Put a new value for 1
$t
    ->put_ok('/data/set/1', json => {name => 'set1.1', 
                                     records => [ $records->[0] ]})
    ->status_is(200)
    ->json_is({message => 'ok', id => 1}, 'Put set update ok');



$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1.1',
                   created_on => 'whatever'}],
                 'Data set 1.1 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->data_sets),
    [{id => 1, name => 'set1.1',
      created_on => 'whatever',
      records => [$records->[0]]}],
    'Data sets are correct';

# Make sure id is ignored FIXME or should it be an error?
$t
    ->put_ok('/data/set/1', json => {name => 'set1.2', id => 3,
                                     records => [ $records->[1] ]})
    ->status_is(200)
    ->json_is({message => 'ok', id => 1}, 
              'Put set update with redundant id ignored ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1.2',
                   created_on => 'whatever'}],
                 'Data set 1.2 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->data_sets),
    [{id => 1, name => 'set1.2',
      created_on => 'whatever',
      records => [$records->[1]]}],
    'Data sets are correct';


# Put a new value for 1
$t
    ->put_ok('/data/set/3', json => {name => 'set3', id => 7})
    ->status_is(200)
    ->json_is({message => 'ok', id => 3}, 'Put create new set id 3 ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1.2',
                   created_on => 'whatever'},
                   {id => 3, name => 'set3',
                    created_on => 'whatever'}],
                 'Data sets 1.2 and 3 are listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->data_sets),
    [{id => 1, name => 'set1.2',
      created_on => 'whatever',
      records => [$records->[1]]},
     {id => 3, name => 'set3',
      created_on => 'whatever',
      records => []}],
    'Data sets are correct';

# Delete 1
$t
    ->delete_ok('/data/set/3')
    ->status_is(200)
    ->json_is({message => 'ok', id => 3}, 'Delete set id 3 ok');

$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1.2',
                   created_on => 'whatever'}],
                 'Data sets 1.2 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->data_sets),
    [{id => 1, name => 'set1.2',
      created_on => 'whatever',
      records => [$records->[1]]}],
    'Data sets are correct';

# FIXME edge cases... logout?
# FIXME multi-set post? delete?
# FIXME set data

done_testing;
