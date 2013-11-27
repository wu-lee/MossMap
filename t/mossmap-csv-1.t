#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use IO::File;
use IO::String;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/../local/lib/perl5";
use lib "$Bin/lib";
use MossMap::CSV;

use Test::DataDirs::Exporter;

# Test opening various sources using mk_row_iterator and
# mk_filtered_row_iterator

my $parser = MossMap::CSV->new;
isa_ok $parser, 'MossMap::CSV';

sub csv { 
    my $row = shift or return;
    return join ",", map qq("$_"), @$row;
}

my $csvfile = "$data_dir/data.csv";
my $csv = Text::CSV->new;

open my $fh, "<", $csvfile
    or die $!;
my $rows = $csv->getline_all($fh);
close $fh;


sub cases {
    my $ix = 0;

    my @cases = (
        [filename => $csvfile],
        [arrayref =>  [map { csv $_ } @$rows]],
        [coderef => sub { csv $rows->[$ix++] }],
        [globref => do { open *IO, "<", $csvfile and \*IO }],
        ['IO::File' => IO::File->new($csvfile)],
        ['IO::String' => IO::String->new(join "\n", map { csv $_ } @$rows)],
    );

    if ($] >= 5.008) { # Perl understands opening string refs
        push @cases, [string => do {
            my $str = join "\n", map { csv $_ } @$rows;
            open my $fh, "<", \$str or die $!;
            $fh;
        }],
    }

    return @cases;
}


# Test mk_row_iterator
for my $case (cases) {
    my ($name, $source) = @$case;
    my $iter = $parser->mk_row_iterator($source);

    my $headings = $iter->();
    is_deeply $headings, $rows->[0], 
        "mk_row_iterator: correct headers read from '$name'"; 

    my $row = $iter->();
    is_deeply $row, $rows->[1], "mk_row_iterator: correct row read from '$name'";
}

# Test mk_filtered_row_iterator
my $expected_row = [@{$rows->[1]}[0,2,4,5]];
$expected_row->[3] = [split /\s*;\s*/, $expected_row->[3]];
for my $case (cases) {
    my ($name, $source) = @$case;
    my $iter = $parser->mk_filtered_row_iterator($source);

    my $got = [ $iter->() ];
    # print explain $got;
    is_deeply $got, $expected_row,
        "mk_filtered_row_iteratorL correct row read from '$name'";
}

# FIXME test dupe and missing headings

done_testing;

