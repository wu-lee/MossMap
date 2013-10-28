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

sub _hash {
    $_[0]->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return $_[0];
}

# Shortcut which gets a hashref-inflated result set
sub _hrs {
    my $self = shift;
    my $rs = _hash $self->_schema->resultset(@_);
    return $rs;
}

sub _records_for_set {
    my ($self, $id) = @_;

    return $self->_rs('Record')->search(
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
}

sub _completed_tetrads_for_set {
    my ($self, $id) = @_;
    
    return $self->_rs('CompletedTetrad')->search(
        { completion_set_id => $id },
        { select => ['grid_ref'],
          as => ['grid_ref'],
          order_by => [qw(grid_ref)] },
    );
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
    $rs = $rs->search(
        undef,
        {prefetch => {'records' => ['recorder','taxon']}}
    );
    return [_hash($rs)->all];
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

# Gets a data set as a hash given the id
sub get_current_data_set {
    my $self = shift;
    my $name = shift;

    my $rs = $self->_rs('DataSet')->search(
        {'me.name' => $name},
        {rows => 1,
         order_by => { -desc => 'me.id' },
         prefetch => {'records' => ['recorder','taxon']}},
    );
    
    return _hash($rs)->first;
}

# Deletes a data set given the id. Returns true
sub delete_data_set {
    my $self = shift;
    my $id = shift;

    my $rs = $self->_rs('DataSet')->find({id => $id})->delete;
    
    return 1;
}

sub new_csv_data_set {
    croak "this method should be called in list context"
        if defined wantarray
        && !wantarray;

    my $self = shift;
    my $name = shift
        or croak "Please supply a name parameter";
    my $source = shift
        or croak "Please supply a CSV data source";

    my @log;
    my $csv = MossMap::CSV->new(
        trace_cb => sub { push @log, @_ },
    );
    my $iterator = $csv->mk_filtered_row_iterator($source);

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

    return $rs->id, \@log;
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

    my $rs = $self->_records_for_set($id);
    
    my $cursor = $rs->cursor;
    $self->_nest_onto(\@data, sub { $cursor->next });

    return \@data;
}


# Get a ref to an array of all data sets (without the records).
sub completion_sets_index {
    my $self = shift;
    
    my $rs = $self->_hrs('CompletionSet');
    return [$rs->all];
}


sub new_csv_completion_set {
    croak "this method should be called in list context"
        if defined wantarray
        && !wantarray;

    my $self = shift;
    my $name = shift
        or croak "Please supply a name for this completion set";
    my $source = shift
        or croak "Please supply a CSV data source";

    my @log;
    my $csv = MossMap::CSV->new(
        trace_cb => sub { push @log, @_ },
    );
    my $iterator = $csv->mk_row_iterator($source);

    my $headings = $iterator->();
    my ($col_ix) = grep { lc $headings->[$_] eq 'tetrad' } 0..$#$headings;
    my @tetrads;
    while(my $fields = $iterator->()) {
        push @tetrads, {grid_ref => $fields->[$col_ix]};
    }

    my $completion_set = { 
        name => $name,
        completed_tetrads => \@tetrads
    };

    my $rs = $self->_rs('CompletionSet')->create($completion_set);

    return $rs->id, \@log;
}


# Gets a completion set in bulk format given the id
sub get_bulk_completion_set {
    my $self = shift;
    my $id = shift;

    my ($dataset) = $self->_hrs('CompletionSet')
        ->find({id => $id});

    return
        unless $dataset;

    # If we get here we retrieved something
    my @data = ($dataset->{name}, $dataset->{created_on});

    my $rs = $self->_rs('CompletedTetrad')->search(
        { completion_set_id => $id },
        { select => ['grid_ref'],
          as => ['grid_ref'],
          order_by => [qw(grid_ref)] },
    );

    my $cursor = $rs->cursor;
    my $tetrad;
    push @data, $tetrad
        while ($tetrad) = $cursor->next;

    return \@data;
}

# get the latest set / completed set with a given name
sub get_bulk_latest {
    my $self = shift;
    my $name = shift;

    my $rs =
        $self->_rs('DataSet')
            ->search(
                {name => $name},
                {rows => 1,
                 order_by => { -desc => 'created_on' }},
            );
    my $dataset = $rs->first;

    return
        unless $dataset;

    # If we get here we retrieved something
    my $records = $self->_records_for_set($dataset->id);

    $dataset = [$dataset->name, $dataset->created_on];

    my $cursor = $records->cursor;
    $self->_nest_onto($dataset, sub { $cursor->next });


    my $completed_set = $self->_hrs('CompletionSet')
        ->search(
            {name => $name},
            {rows => 1,
             order_by => { -desc => 'created_on' }},
        )
        ->first;

    my @completed;
    if ($completed_set) {
        $rs = $self->_completed_tetrads_for_set($completed_set->id);
        
        $cursor = $rs->cursor;
        @completed = ($completed_set->name, $completed_set->created_on);
        my $tetrad;
        push @completed, $tetrad
            while ($tetrad) = $cursor->next;
    }

    return {taxa => $dataset,
            completed => \@completed};
}



no Carp;
1;
