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
my $csv_completion_sets = MyTest::Data->bulk_csv_completions;

for my $ix (0..$#$csv_sets) {
    my $name = "set".($ix+1);
    $t->app->model->new_csv_data_set(
        $name, IO::String->new($csv_sets->[$ix]),
    );
    $t->app->model->new_csv_completion_set(
        $name, IO::String->new($csv_completion_sets->[$ix]),
    );
}

my $bulk_sets = MyTest::Data->bulk_json_sets;
my $set_index = [];
for my $ix (0..$#$csv_sets) {
    my $index = {
        id => $ix+1,
        name => "set".($ix+1),
        created_on => 'whatever',
    };

    push @$set_index, $index;
}

my $completion_set_index = [];
for my $ix (0..$#$csv_completion_sets) {
    my $index = {
        id => $ix+1,
        name => "set".($ix+1),
        created_on => 'whatever',
    };

    push @$completion_set_index, $index;
}

# Check we can list the datasets
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is($set_index, 
                 '/data/sets is correct');

# Check we can access the data
$t
    ->get_ok('/bulk/sets/1')
    ->status_is(200)
    ->my_json_is($bulk_sets->[0]{taxa}, 
              '/bulk/sets/1 is correct');

# Check we can't set data before logging in
$t
    ->post_ok('/bulk/sets.csv', form => {upload => {content => $csv_sets->[0]}})
    ->status_is(401)
    ->json_is({error => 'Unauthorized'},
              'Unauthorized /bulk/sets.csv is 401');


# Check we can't completion set data before logging in
$t
    ->post_ok('/bulk/completed.csv', form => {
        upload => {content => $csv_completion_sets->[0]},
    })
    ->status_is(401)
    ->json_is({error => 'Unauthorized'},
              'Unauthorized /bulk/completed.csv is 401');


# Log in
$t
    ->post_ok('/session/login', json => {username => 'user1', password => 'secret'})
    ->status_is(200)
    ->json_is({message => 'logged in', username => 'user1'},
              'Login ok');

# Ensure set 3 is absent
$t
    ->get_ok('/bulk/sets/3')
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
    ->json_is({message => 'ok', id => 3,
               csv_messages => MyTest::Data->expected_csv_logs},
              'Posted set ok');

sub _rename_to {
    my ($filename, $data) = @_;
    return [$filename, @$data[1..$#$data]];
}

# Check we can get it back
$t
    ->get_ok('/bulk/sets/3')
    ->status_is(200)
    ->my_json_is(_rename_to('some-filename.csv', 
                            $bulk_sets->[0]{taxa}),
                 '/bulk/sets/3 is correct');


# Check we can post a completion set
$t
    ->post_ok('/bulk/completed.csv', form => {
        upload => {
            content => $csv_completion_sets->[0],
            filename => "some-other-filename.csv",
        },
    })
    ->status_is(201)
    ->json_is({message => 'ok', id => 3,
               csv_messages => []},
              'Posted completions ok');


# Check we can get it back
$t
    ->get_ok('/bulk/completed/3')
    ->status_is(200)
    ->my_json_is(_rename_to('some-other-filename.csv',
                            $bulk_sets->[0]{completed}),
                 '/bulk/completed/3 is correct');

# Check index
$t
    ->get_ok('/data/completions')
    ->status_is(200)
    ->my_json_is([@$completion_set_index, 
                  {id => 3,
                   name => "some-other-filename.csv",
                   created_on => 'whatever'}],
                 '/data/sets is correct');


# Check index again
$t
    ->get_ok('/data/sets')
    ->status_is(200)
    ->my_json_is([@$set_index, 
                  {id => 3,
                   name => "some-filename.csv",
                   created_on => 'whatever'}],
                 '/data/sets is correct');

# Check we can get the full monte
# containing the latest sets
$t
    ->get_ok('/bulk/latest/set1')
    ->status_is(200)
    ->my_json_is($bulk_sets->[0],
                 '/bulk/latest/set1 is correct');

done_testing;
