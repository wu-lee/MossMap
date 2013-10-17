#!/usr/bin/perl
package main;
use strict;
use warnings;
use JSON::PP;
use FindBin qw($Bin);
use lib "$Bin/ll/lib/perl5";
use lib "$Bin/lib";

use MossMap::CSV;

my $csv_file = shift
    or die "you must supply the name of a CSV data file\n";
    
open my $fh, "<:encoding(utf8)", $csv_file or die "$csv_file: $!";

my $csv = MossMap::CSV->new(
    trace_cb => sub { warn @_ },
);
my $list = $csv->bulk_json($fh);

close $fh;

my $json = JSON::PP->new->ascii; #->pretty->allow_nonref;
print $json->encode($list);
