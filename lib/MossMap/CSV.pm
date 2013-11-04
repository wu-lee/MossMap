package MossMap::CSV;
use strict;
use warnings;
use Text::CSV;
use Time::Local;
use Carp qw(croak);

my @dinty = map { [split '', $_] } reverse (
    'EJPUZ',
    'DINTY',
    'CHMSX',
    'BGLRW',
    'AFKQV',
);

my %filters = (
    keep_all => sub { shift },

    keep_tetrad_attributable => sub {
        my ($row, $trace) = @_;

        # Reject grid-refs with precision less than
        # PQnnR (tetrad)
        my $grid_ref = $row->{grid_ref};
        my $len = length $grid_ref;
        if ($len < 5) {
            $trace->("discarding as too coarse: $grid_ref\n");
            return;
        }
            
        if ($len == 5) {
            return $row;
        }

        # Convert other grid-refs to tetrad precision
        my $rx = (qr/^(..)(.)(.)(.)(.)$/,
                  undef,
                  qr/^(..)(.)(.).(.)(.).$/,
                  undef,
                  qr/^(..)(.)(.)..(.)(.)..$/,
                  undef,
                  qr/^(..)(.)(.)...(.)(.)...$/)[$len-6];
        croak "invalid grid ref '$grid_ref'"
            unless $rx;


        $row->{grid_ref} =~ s/$rx/join('',$1,$2,$4,$dinty[$5>>1][$3>>1])/e;
        $trace->("converting grid-ref to tetrad: $grid_ref -> $row->{grid_ref}\n");
        return $row;
    },
);

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

    # Converts a delimited list of recorders into an array ref
    # Trims whitespace.
    recorders => sub {
        my $row = shift;
        my $recorder = $row->{Recorder};
        
        return [ grep { length $_ } 
                 map  { /^\s*(.*?)\s*$/sm }
                 split ';', $recorder        ];
    },
);


sub new {
    my $class = shift;
    my %params = @_;

    my $csv = Text::CSV->new({
        binary => 1,  # should set binary attribute.
        auto_diag => 1,
    })
        or croak "Cannot use CSV: ".Text::CSV->error_diag ();

    return bless {
        csv => $csv,
        filter => $filters{keep_tetrad_attributable},
        trace_cb => $params{trace_cb} || sub {},
    }, $class;
}

sub heading_map { \@heading_map }

sub filters { \%filters }

# Returns a subref which iterates over CSV data, returning an
# array-ref of data with no filtering (including the heading line),
# and no interpretation of the rows.
# Returns an empty list when there is no more data.
sub mk_row_iterator {
    my $self = shift;
    my $source = shift
        or croak "Please supply a data source as the first parameter";

    my $iterator;
    my $ix = 0;
    my $csv = $self->{csv};

    # Map scalars or arrayrefs into filehandles or coderefs, respectively
    if (!ref $source) {
        $source = IO::File->open($source);
    }
    elsif (ref $source eq 'ARRAY') {
        $source = sub { $source->[$ix++] };
    }

    # Create an iterator for coderef or filehandle sources
    if (ref $source eq 'CODE') {
        $iterator = sub {
            my $line = $source->();
            return ($line && $csv->parse($line));
        };
    }
    elsif (ref $source eq 'GLOB'
        || $source->isa('IO::Handle')
        || $source->isa('IO::String')) {
        $iterator = sub { $csv->getline($source) }
    }

    $iterator
        or croak "You have not supplied a valid data source: $source";

    return $iterator;
}

# Returns a subref which iterates over the CSV data, returning a
# list of valid, normalised data items.  You won't see the
# headings, and returned items are taxon, grid_ref, date, and recorder.
sub mk_filtered_row_iterator {
    my $self = shift;
    
    my $iterator = $self->mk_row_iterator(@_);

    my $headings = $iterator->();
    $headings && @$headings
        or croak "No headings found\n";

    my %csv_row;

    return sub {
        while ( my $csv_row_ref = $iterator->() ) {
            @csv_row{@$headings} = @$csv_row_ref;

            my $row;
            
            for(my $ix = 0; $ix < @heading_map; $ix += 2) {
                my ($fields, $mapper) = @heading_map[$ix, $ix+1];
                $fields = [$fields] 
                    unless ref $fields;
                
                my $value = $mapper;
                $mapper = sub { $_[0]->{$value} }
                    unless ref $mapper;
                
                @$row{@$fields} = $mapper->(\%csv_row);
            }
            
            # Optionally discard data points
            next
                unless $row = $self->{filter}->($row, $self->{trace_cb});

            return @$row{qw(taxon grid_ref date recorders)};
        }

        # If we get here we ran out of data
        return;
    };
}

sub bulk_json {
    my $self = shift;
    my $iterator = $self->mk_filtered_row_iterator(@_);

    my %index;
    while ( my ($taxon, $grid_ref, $date, $recorder) = $iterator->() ) {
        $index{$taxon}{$grid_ref}{$date}++;
    }

    # Reformat the %index into a @list

    # Sort records by gridref precision, so that large circles
    # rendered before small ones.  This means that the former don't
    # eclipse the latter.  Handily, a gridref's precision is related
    # to its length in characters (the longer the higher the
    # precision)
    my @list = map {
        my $taxon = $_;
        my $locations = $index{$taxon};
        [
            $taxon,
            [
                map {
                    my $gridref = $_;
                    my $dates = $locations->{$gridref};
                    [ $gridref, $dates ];
                } sort { length $a <=> length $b ||
                             $a cmp $b } keys %$locations
            ]
        ];
    } sort keys %index;
 
    return \@list;
}

no Carp;
1;
