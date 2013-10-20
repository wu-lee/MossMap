#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 8;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/../ll/lib/perl5";
#require "$Bin/../csv2json.pl";
use MossMap::CSV;

my $parser = MossMap::CSV->new;
isa_ok $parser, 'MossMap::CSV';

# Test the main filter

my $filter = MossMap::CSV->filters->{keep_tetrad_attributable};
my $nop = sub {};

ok !$filter->({grid_ref => 'SJ'}, $nop);
ok !$filter->({grid_ref => 'SJ12'}, $nop);
is_deeply $filter->({grid_ref => 'SJ1234'}, $nop),   {grid_ref => 'SJ13H'};
is_deeply $filter->({grid_ref => 'SJ5083'}, $nop),   {grid_ref => 'SJ58B'};
is_deeply $filter->({grid_ref => 'SJ509829'}, $nop), {grid_ref => 'SJ58B'};
is_deeply $filter->({grid_ref => 'SJ510831'}, $nop), {grid_ref => 'SJ58B'};
is_deeply $filter->({grid_ref => 'SJ5182'}, $nop),   {grid_ref => 'SJ58B'};
