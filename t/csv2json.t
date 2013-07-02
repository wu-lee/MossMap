#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 8;
use FindBin qw($Bin);
require "$Bin/../csv2json.pl";

my $parser = CSV2JSON->new;
isa_ok $parser, 'CSV2JSON';

# Test the main filter

my $filter = CSV2JSON->filters->{keep_tetrad_attributable};

ok !$filter->({grid_ref => 'SJ'});
ok !$filter->({grid_ref => 'SJ12'});
is_deeply $filter->({grid_ref => 'SJ1234'}),   {grid_ref => 'SJ13H'};
is_deeply $filter->({grid_ref => 'SJ5083'}),   {grid_ref => 'SJ58B'};
is_deeply $filter->({grid_ref => 'SJ509829'}), {grid_ref => 'SJ58B'};
is_deeply $filter->({grid_ref => 'SJ510831'}), {grid_ref => 'SJ58B'};
is_deeply $filter->({grid_ref => 'SJ5182'}),   {grid_ref => 'SJ58B'};
