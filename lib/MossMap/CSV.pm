package MossMap::CSV;
use strict;
use warnings;
use Text::CSV;
use Time::Local;
use Carp qw(croak);
use Scalar::Util qw(blessed);

my $noop = sub {};

my @dinty = map { [split '', $_] } reverse (
    'EJPUZ',
    'DINTY',
    'CHMSX',
    'BGLRW',
    'AFKQV',
);

# List of regexes indexed by string length
my @rx_index = do {
    my $AZ = qr/[A-Z]{2}/;
    
    (
        undef,
        undef,
        qr/($AZ)/x,
        undef,
        qr/($AZ) \d\d/x,
        qr/($AZ) (\d) (\d) ([A-Z])/x, # Tetrad, special case, 4 matches
        qr/($AZ) (\d)(\d) (\d)(\d)/x,
        undef,
        qr/($AZ) (\d)(\d)\d (\d)(\d)\d/x,
        undef,
        qr/($AZ) (\d)(\d)\d\d (\d)(\d)\d\d/x,
        undef,
        qr/($AZ) (\d)(\d)\d\d\d (\d)(\d)\d\d\d/x
    );
};
    
my %filters = (
    keep_all => sub { shift },

    keep_tetrad_attributable => sub {
        my ($row, $trace) = @_;

        # Ignore undefined gridrefs
        if (!defined $row->{grid_ref}) {
            $trace->("discarding as undefined grid ref");
            return;
        }

        # trim whitespace
        s/^\s+//sm, s/\s+$//sm for $row->{grid_ref};

        my $grid_ref = $row->{grid_ref};
        my $len = length $grid_ref;

        # Check for empties
        if ($len == 0) {
            croak "empty grid ref $grid_ref";
        }

        # Convert other grid-refs to tetrad precision
        my $rx = $rx_index[$len];
        croak "invalid grid ref '$grid_ref' has bad length ($len)"
            unless $rx;
        
        if ($len < 5) {
            # We're being strict and checking even GRs we'd discard.
            croak "invalid grid ref '$grid_ref'"
                unless $grid_ref =~ /^$rx$/;
            
            $trace->("discarding as too coarse: $grid_ref");
            return;
        }
        
        if ($len == 5) {
            croak "invalid grid ref '$grid_ref' has 5 characters but is not a tetrad"
                unless $row->{grid_ref} =~ s/^$rx$/uc $&/ie;
            return $row;
        }

        croak "invalid grid ref '$grid_ref'"
            unless $row->{grid_ref} =~
                s/^$rx$/join('',uc($1),$2,$4,$dinty[$5>>1][$3>>1])/ie;

        $trace->("converting grid-ref to tetrad: $grid_ref -> $row->{grid_ref}");
        return $row;
    },
);

# Defines what we keep, and name mappings thereof
my @heading_map = (
    taxon => 'taxon',
    grid_ref => 'gr',
    
    # Dates are formatted as either '', 'YYYY', 'YYYYMM', or 'YYYYMMDD'
    # depending on the precision
    date => sub {
        my $row = shift;
        my ($y, $m, $d) = map { 
            (!defined) ? '' :
            /^#VALUE!$/? '' :
            /^\s*$/    ? '' :
                int;
        } @$row{qw(year month day)};

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
        my $recorder = $row->{recorder};

        return ''
            unless defined $recorder;

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
        trace_cb => $params{trace_cb} || $noop,
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
        require 'IO/File.pm';
        my $fh = IO::File->new($source, "r")
            or croak "Failed to open file '$source': $!";
        $source = $fh;
    }
    elsif (ref $source eq 'ARRAY') {
        my $ary = $source;
        $source = sub { $ary->[$ix++] };
    }

    # Create an iterator for coderef or filehandle sources
    if (ref $source eq 'CODE') {
        $iterator = sub {
            my $line = $source->();
            return ($line && $csv->parse($line) && [$csv->fields]);
        };
    }
    elsif (ref $source eq 'GLOB') {
        $iterator = sub { $csv->getline($source) }
    }
    elsif (!blessed $source) {
        # drop non-blessed scalars now
    }
    elsif ($source->isa('IO::Handle')
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
    my $trace = $self->{trace_cb} || $noop;
    
    my $iterator = $self->mk_row_iterator(shift, $trace);

    my $headings = $iterator->();
    $headings && @$headings
        or croak "No headings found\n";

    # Normalise by stripping non alpha-numeric chars, and lower-casing.
    # Some additional special-case mapping too.
    my %count;
    s/[\W_]+//g, $_ = lc, s/^recorders$/recorder/, 
        s/^gridref.*/gr/, $count{$_}++
            for @$headings;

    # Warn about missing and duplicate headings
    {
        no warnings 'uninitialized'; # some of these $count{}s may be undefined
        my @missing = grep { $count{$_} < 1 } qw(taxon gr recorder year);
        
        @missing 
            and croak "These mandatory headings are missing even after ".
                "normalising the input headings: @missing";

        my @dupes = grep { $count{$_} > 1 } qw(taxon gr recorder year month day);
        @dupes
            and $trace->(
                "these headings are duplicated after normalising, ".
                "so you may not be getting the result you expect: @dupes"
            );
    }
    
    return sub {
        my %csv_row;
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

sub trace { 
    my $self = shift;
    return $self->{trace_cb}
        unless @_;
    $self->{trace_cb} = shift;
    return $self;
}

no Carp;
1;
