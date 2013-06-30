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

my @dinty = map { [split '', $_] } reverse (
    'EJPUZ',
    'DINTY',
    'CHMSX',
    'BGLRW',
    'AFKQV',
);

my %filters = (
    keep_all => sub { 1 },

    keep_tetrad_attributable => sub {
        my $row = shift;

        # Reject grid-refs with precision less than
        # PQnnR (tetrad)
        my $grid_ref = $row->{grid_ref};
        my $len = length $grid_ref;
        if ($len < 5) {
            warn "discarding as too coarse: $grid_ref\n";
            return;
        }
            
        if ($len == 5) {
            return 1;
        }

        # Convert other grid-refs to tetrad precision
        my $rx = (qr/^(..)(.)(.)(.)(.)$/,
                  undef,
                  qr/^(..)(.)(.).(.)(.).$/,
                  undef,
                  qr/^(..)(.)(.)..(.)(.)..$/,
                  undef,
                  qr/^(..)(.)(.)...(.)(.)...$/)[$len-6];
        die "invalid grid ref '$grid_ref'"
            unless $rx;


        $row->{grid_ref} =~ s/$rx/join('',$1,$2,$4,$dinty[$5>>1][$3>>1])/e;
#        warn "$grid_ref => $row->{grid_ref}: $1$2$4 $3$5 ".$dinty[$5>>1][$3>>1]."\n";  # DEBUG
        warn "converting grid-ref to tetrad: $grid_ref -> $row->{grid_ref}\n";
        return 1;
    },
);

my $is_keeper = $filters{keep_tetrad_attributable};

# Defines what we keep, and name mappings thereof
my @heading_map = (
    taxon => 'Taxon',
    grid_ref => 'GR',

    # Dates are formatted as either '', 'YYYY', 'YYYYMM', or 'YYYYMMDD'
    # depending on the precision
    date => sub {
        my $row = shift;
        my ($y, $m, $d) = map { 
            (!defined) ? '' :
            /^#VALUE!$/? '' :
            /^\s*$/    ? '' :
                int;
        } @$row{qw(Year Month Day)};

        return sprintf '%04u%02u%02u', $y, $m, $d
            if length($y) && length($m) && $d;
        
        return sprintf '%04u%02u', $y, $m
            if length($y) && length($m);
            
        return sprintf '%04u', $y
            if length($y);

        return '';
    },
);

my %index;
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

    # Optionally discard data points
    next unless $is_keeper->(\%row);

    my $taxon = delete $row{taxon};
    my $grid_ref = delete $row{grid_ref};
    my $date = delete $row{date};
    my $list = $index{$taxon}{$grid_ref} ||= [];
    
    push @$list, $date;
}

$csv->eof or $csv->error_diag();
close $fh;

# reformat the %index into a @list
# Sort records by gridref precision, so that large circles rendered before small ones.
# This means that the former don't eclipse the latter.  Handily, a gridref's precision
# is related to its length in characters (the longer the higher the precision)
my @list = map {
    my $taxon = $_;
    my $locations = $index{$taxon};
    [
        $taxon,
        [
            map {
                my $gridref = $_;
                my $dates = $locations->{$gridref};
                [ $gridref, @$dates ];
            } sort { length $a <=> length $b } keys %$locations
        ]
    ];
} sort keys %index;

use JSON::PP;
my $json = JSON::PP->new->ascii; #->pretty->allow_nonref;
print $json->encode(\@list);
#print "$_\n" for sort keys %taxon;

