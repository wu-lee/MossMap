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
use IO::String;

require "$Bin/../moss-map.pl";

my $t = MyTest::Mojo->new;

# Populate the (assumed empty) test database
$t->app->model->_schema->deploy;
#$t->app->model->_debug(1);

# populate the database
my $csv_sets = MyTest::Data->bulk_csv_sets;
for my $ix (0..$#$csv_sets) {
    $t->app->model->new_csv_data_set("set".($ix+1), IO::String->new($csv_sets->[$ix]));
}

my $bulk_sets = MyTest::Data->bulk_json_sets;
my $set_index = [];
#my $bulk_sets = [];
for my $ix (0..$#$csv_sets) {
    my $index = {
        id => $ix+1,
        name => "set".($ix+1),
        created_on => 'whatever',
    };

    push @$set_index, $index;

}



# Check we can list the datasets
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is($set_index, 
                 '/data/sets is correct');

# Check we can access the data
$t
    ->get_ok('/bulk/set/1')
    ->status_is(200)
    ->my_json_is({
        completed => [],
        taxa => ['set1','whatever', @{ $bulk_sets->[0] }],
    }, 
              '/bulk/set/1 is correct');

# Check we can't set data before logging in
$t # FIXME
    ->post_ok('/bulk/sets.csv', form => {upload => {content => $csv_sets->[0]}})
    ->status_is(401)
    ->json_is({error => 'Unauthorized'},'Unauthorized /bulk/sets.csv is 401');


# Log in
$t
    ->post_ok('/login.json', json => {user => 'user1', password => 'secret'})
    ->status_is(200)
    ->json_is({message => 'ok'}, 'Login ok');

# Ensure set 3 is absent
$t
    ->get_ok('/bulk/set/3')
    ->status_is(404)
    ->json_is({id => 3, error => 'Invalid id'}, 'Data set 3 is absent');

# Check we can set data
$t
    ->post_ok('/bulk/sets.csv', form => {
        upload => {
            content => $csv_sets->[0],
            filename => "some-filename.csv",
        },
    })
    ->status_is(201)
    ->json_is({message => 'ok', id => 3}, 'Posted set ok');


# Check we can get it back
$t
    ->get_ok('/bulk/set/3')
    ->status_is(200)
    ->my_json_is({
        completed => [],
        taxa => ['some-filename.csv','whatever', @{ $bulk_sets->[0] }],
    },
                 '/bulk/set/3 is correct');

# Check index
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([@$set_index, 
                  {id => 3,
                   name => "some-filename.csv",
                   created_on => 'whatever'}],
                 '/data/sets is correct');



done_testing;
