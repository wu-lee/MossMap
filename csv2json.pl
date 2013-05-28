#!/usr/bin/perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/ll/lib/perl5";

use Text::CSV;
use Time::Local;

my $csv_file = shift
    or die "you must supply the name of a CSV data file\n";



my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
    or die "Cannot use CSV: ".Text::CSV->error_diag ();
 
open my $fh, "<:encoding(utf8)", $csv_file or die "$csv_file: $!";
my $headings = $csv->getline( $fh );

$headings && @$headings
    or die "No headings found\n";

sub datestr {
    sprintf "%04u-%02u-%02u", @_;
}

# Defines what we keep, and name mappings thereof
my @heading_map = (
    taxon => 'Taxon',
    grid_ref => 'GR',
    ['period', 'date'] => sub {
        my $row = shift;
        my ($y, $m, $d) = map { 
            (!defined) ? '' :
            /^#VALUE!$/? '' :
            /^\s*$/    ? '' :
                int;
        } @$row{qw(Year Month Day)};

        return day => datestr($y,$m,$d)
            if length($y) && length($m) && $d;
        
        return month => datestr($y,$m,1)
            if length($y) && length($m);
            
        return year => datestr($y,1,1)
            if length($y);

        return 'undefined' => '';
    },
);

my %data;
my %taxon;
my %csv_row = map { $_ => undef } @heading_map;
while ( my $csv_row_ref = $csv->getline( $fh ) ) {
    @csv_row{@$headings} = @$csv_row_ref;

    my %row;

    for(my $ix = 0; $ix < @heading_map; $ix += 2) {
        my ($fields, $mapper) = @heading_map[$ix, $ix+1];
        $fields = [$fields] 
            unless ref $fields;
        
        my $value = $mapper;
        $mapper = sub { $_[0]->{$value} }
            unless ref $mapper;

        @row{@$fields} = $mapper->(\%csv_row);
    }

    my $taxon = delete $row{taxon};
    my $grid_ref = delete $row{grid_ref};
    my $list = $data{$taxon}{$grid_ref} ||= [];
    push @$list, \%row;
}

$csv->eof or $csv->error_diag();
close $fh;

use JSON::PP;
my $json = JSON::PP->new->ascii->pretty->allow_nonref;
print $json->encode(\%data);
#print "$_\n" for sort keys %taxon;

