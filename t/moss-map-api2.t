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

my $records = [
    { id => 1, data_set_id => 1, grid_ref => 'sj1234', taxon => {id => 1, name => 'foo'}, recorder => {id => 1, name => 'alice'}, recorded_on => '2011-11-11'},
    { id => 2, data_set_id => 1, grid_ref => 'sj1234', taxon => {id => 2, name => 'goo'}, recorder => {id => 2, name => 'bob'}, recorded_on => '2012-12-12'},
];

my $completed = [
   
        map {{ grid_ref => $_ }}
            qw(SJ79B SJ79G SJ79L SJ79R SJ79W SJ89B SJ69V SJ79A SJ79F
               SJ79K SJ79Q)
        ];
#    [
#        map {{ grid_ref => $_ }}
#            qw(SJ79V SJ18Z SJ68E SJ68J SJ68P SJ68U SJ68Z SJ78E SJ88P SJ18Y)
#    ]
#];

# Return selected items from the above records with their IDs
# reassigned.
sub records {
    my $id = pop or die;
    [ map {{ %{ $records->[$_] }, data_set_id => $id }} @_ ]
}

sub completed {
    my $id = pop or die;
    [ map {{ %{ $completed->[$_] }, completion_set_id => $id }} @_ ]
}


# Check our database is empty
$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->json_is([],'completed_sets is empty');
 
# Authenticate
$t
    ->post_ok('/data/completed')
    ->status_is(401)
    ->json_is({error => 'Unauthorized'},'Unauthorized error result');

$t
    ->post_ok('/session/login', json => {username => 'user1',
                                         password => 'secret'})
    ->status_is(200)
    ->json_is({message => 'logged in', username => 'user1'},
              'Login ok');


# Invalid item id 1
$t
    ->get_ok('/data/completed/1')
    ->status_is(404)
    ->json_is({id => 1, error => 'Invalid name or id'},
              'Completed set 1 is absent');


$t
    ->get_ok('/data/completed/set1')
    ->status_is(404)
    ->json_is({id => 'set1', error => 'Invalid name or id'},
              'No completed set "set1"');

$t
    ->post_ok('/data/completed', json => {
        name => 'set1', 
        completed_tetrads => completed(0,1 => 1)
    })
    ->status_is(201)
    ->json_is({message => 'ok', id => 1}, 'Posted set ok');

# Check our mock database is no-longer empty
$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1',
                   created_on => 'whatever'}],
                 'Completed set 1 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->completed_sets),
    [{id => 1, name => 'set1',
      created_on => 'whatever',
      completed_tetrads => completed(0,1 => 1) }],
    'Completed sets are correct';


# Get the item we just obtained
$t
    ->get_ok('/data/completed/1')
    ->status_is(200)
    ->my_json_is({id => 1, name => 'set1',
                  created_on => 'whatever',
                  completed_tetrads => completed(0,1 => 1)},
                 'Completed set 1 is correct');

$t
    ->get_ok('/data/completed/set1')
    ->status_is(200)
    ->my_json_is({id => 1, name => 'set1',
                  created_on => 'whatever',
                  completed_tetrads => completed(0,1 => 1)},
                 'We can also get is as "set1"');

# Put a new value /  name for 1
$t
    ->put_ok('/data/completed/1', json => {name => 'set1-1', 
                                      completed_tetrads => completed(0 => 1)})
    ->status_is(200)
    ->json_is({message => 'ok', id => 1}, 'Put set update ok');



$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1-1',
                   created_on => 'whatever'}],
                 'Completed set 1-1 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->completed_sets),
    [{id => 1, name => 'set1-1',
      created_on => 'whatever',
      completed_tetrads => completed(0 => 1)}],
    'Completed sets are correct';

# Make sure id is ignored FIXME or should it be an error?
$t
    ->put_ok('/data/completed/1', json => {name => 'set1-2', id => 3,
                                     completed_tetrads => completed(1 => 1)})
    ->status_is(200)
    ->json_is({message => 'ok', id => 1}, 
              'Put set update with redundant id ignored ok');

$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1-2',
                   created_on => 'whatever'}],
                 'Completed set 1-2 is listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->completed_sets),
    [{id => 1, name => 'set1-2',
      created_on => 'whatever',
      completed_tetrads => completed(1 => 1)}],
    'Completed sets are correct';


# Put a new value for 3
$t
    ->put_ok('/data/completed/3', json => {name => 'set3', id => 7})
    ->status_is(200)
    ->json_is({message => 'ok', id => 3}, 'Put create new set id 3 ok');

$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1-2',
                   created_on => 'whatever'},
                   {id => 3, name => 'set3',
                    created_on => 'whatever'}],
                 'Completed sets 1-2 and 3 are listed');

is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->completed_sets),
    [{id => 1, name => 'set1-2',
      created_on => 'whatever',
      completed_tetrads => completed(1 => 1)},
     {id => 3, name => 'set3',
      created_on => 'whatever',
      completed_tetrads => []}],
    'Completed sets are correct';



# Delete 1
$t
    ->delete_ok('/data/completed/3')
    ->status_is(200)
    ->json_is({message => 'ok', id => 3}, 'Delete set id 3 ok');

$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1-2',
                   created_on => 'whatever'}],
                 'Completed sets 1-2 is listed');


is_deeply
    +MyTest::Mojo->date2whatever($t->app->model->completed_sets),
    [{id => 1, name => 'set1-2',
      created_on => 'whatever',
      completed_tetrads => completed(1 => 1)}],
    'Completed sets are correct';

# Post a new set named set1-2
$t
    ->post_ok('/data/completed', json => {name => 'set1-2',
                                     completed_tetrads => completed(0 => 2)})
    ->status_is(201)
    ->json_is({message => 'ok', id => 2}, 'Posted set ok');

# Check the contents
$t
    ->get_ok('/data/completed')
    ->status_is(200)
    ->my_json_is([{id => 1, name => 'set1-2',
                   created_on => 'whatever'},
                  {id => 2, name => 'set1-2',
                   created_on => 'whatever'}],
                 'Completed sets 1-2 is listed');

is_deeply
   +MyTest::Mojo->date2whatever($t->app->model->completed_sets),
   [{id => 1, name => 'set1-2',
     created_on => 'whatever',
     completed_tetrads => completed(1 => 1)},
    {id => 2, name => 'set1-2',
     created_on => 'whatever',
     completed_tetrads => completed(0 => 2)}],
   'Completed sets are correct';

# Check we can get the current set1-2 back by name
$t
    ->get_ok('/data/completed/set1-2')
    ->status_is(200)
    ->my_json_is({id => 2, name => 'set1-2',
                  created_on => 'whatever',
                  completed_tetrads => completed(0 => 2)},
                 'We can get "set1-2"');



done_testing;
