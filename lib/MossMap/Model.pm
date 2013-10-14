package MossMap::Model;
use strict;
use warnings;
use MossMap::Schema;
use MossMap::CSV;
use FindBin;
use Carp qw(croak);

sub new {
    my $class = shift;
    my $db_path = shift
        or croak "you must supply a path to a sqlite database file"; 

    my $schema = MossMap::Schema->connect("dbi:SQLite:$db_path");

    return bless { schema => $schema }, $class;
}

sub _schema { shift->{schema} }

# This allows debugging to be enabled or disabled
sub _debug { shift->_schema->storage->debug(@_); }

# Sortcut which gets a result set
sub _rs {
    my $self = shift;
    my $rs = $self->_schema->resultset(@_);
    return $rs;
}

# Shortcut which gets a hashref-inflated result set
sub _hrs {
    my $self = shift;
    my $rs = $self->_schema->resultset(@_);
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return $rs;
}

sub _nest_onto {
    shift;
    my $data = shift;
    my $cursor = shift;
    
    while (my ($taxon, $gridref, $rec_on, $rec_count) = $cursor->()) {
        my $TAXON = 
            @$data <= 2?              ($data->[2] = [$taxon,[]]) :
            $data->[-1][0] eq $taxon? $data->[-1] :
                                      ($data->[+@$data] = [$taxon,[]]);
        my $GRIDREF = 
            @{$TAXON->[1]} == 0?            ($TAXON->[1][0] = [$gridref, {}]) :
            $TAXON->[1][-1][0] eq $gridref? $TAXON->[1][-1] :
                                           ($TAXON->[1][+@{$TAXON->[1]}] = [$gridref, {}]);

        $GRIDREF->[1]{$rec_on} = $rec_count;
    };

    return $data;
}

# Get a ref to an array of all data sets (without the records).
sub data_sets_index {
    my $self = shift;
    
    my $rs = $self->_hrs('DataSet');
    return [$rs->all];
}

# Get a ref to an array of all data sets (with the records, recorders and taxa)
sub data_sets {
    my $self = shift;
    
    my $rs = $self->_rs('DataSet');
    $rs = $rs->search(undef, {prefetch => {'records' => ['recorder','taxon']}});
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return [$rs->all];
}

# Saves a data set, returns the id
sub set_data_set {
    my $self = shift;
    my $data = shift;

    # FIXME recorders? taxons?

    # We can't insert the datastructure all at once, it seems, so we
    # must take out the records and insert those separately
    # afterwards.
    my $records = delete $data->{records};
    my $dataset = $self->_rs('DataSet')->update_or_create($data);


    # Remove all existing records associated with this set.  (We can't
    # really equate them by ID, we'd have to compare all the fields.
    # Deleting them all seems simpler, if possibly less efficient in
    # some cases).
    $dataset->records->delete;

    # Re-insert the new records
    $dataset->add_to_records( $_ )
        for @$records;

    return $dataset->id;    
}

# Creates a new data set, returns the id
sub new_data_set {
    my $self = shift;
    my $data = shift;

    delete $data->{id};
    my $rs = $self->_rs('DataSet')->create($data);

    return $rs->id;
}

# Gets a data set as a hash given the id
sub get_data_set {
    my $self = shift;
    my $id = shift;

    my $rs = $self->_hrs('DataSet')->find(
        {id => $id},
        {prefetch => {'records' => ['recorder','taxon']}},
    );
    
    return $rs;
}

# Deletes a data set given the id. Returns true
sub delete_data_set {
    my $self = shift;
    my $id = shift;

    my $rs = $self->_rs('DataSet')->find({id => $id})->delete;
    
    return 1;
}

sub new_csv_data_set {
    my $self = shift;
    my $name = shift
        or croak "Please supply a name parameter";
    my $source = shift
        or croak "Please supply a CSV data source";

    my $iterator = MossMap::CSV->new->mk_filtered_row_iterator($source);

    my @records;
    while(my @fields = $iterator->()) {
        my %record;
        $record{taxon} = { name => $fields[0] };
        $record{recorder} = { name => $fields[3] };
        @record{qw(grid_ref recorded_on)} = @fields[1,2];
        push @records, \%record;
    }

    my $dataset = { 
        name => $name,
        records => \@records
    };

    my $rs = $self->_rs('DataSet')->create($dataset);

    return $rs->id;
}

# Gets a data set in bulk format given the id
sub get_bulk_data_set {
    my $self = shift;
    my $id = shift;

    my ($dataset) = $self->_hrs('DataSet')
        ->find({id => $id});

    return
        unless $dataset;

    # If we get here we retrieved something
    my @data = ($dataset->{name}, $dataset->{created_on});

    my $rs = $self->_rs('Record')->search(
        { data_set_id => $id },
        { select => ['taxon.name', 
                     'grid_ref',
                     'recorded_on',
                     { count => 'grid_ref' }],
          as => ['taxon', 'grid_ref', 'recorded_on', 'record_count'],
          join => ['taxon'],
          group_by => [qw(taxon.name grid_ref)],
          order_by => [qw(taxon.name grid_ref recorded_on)] },
    );

    my $cursor = $rs->cursor;
    $self->_nest_onto(\@data, sub { $cursor->next });

    return {
        completed => [],
        taxa => \@data,
    };
}


no Carp;
1;
