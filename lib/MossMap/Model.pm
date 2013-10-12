package MossMap::Model;
use strict;
use warnings;
use MossMap::Schema;
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

# Get a ref to an array of all data sets
sub data_sets {
    my $self = shift;
    
    my $rs = $self->_hrs('DataSet');
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

no Carp;
1;
