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

sub _rs {
    my $self = shift;
    my $rs = $self->_schema->resultset(@_);
    return $rs;
}
sub _hrs {
    my $self = shift;
    my $rs = $self->_schema->resultset(@_);
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return $rs;
}

sub data_sets {
    my $self = shift;
    
    my $rs = $self->_hrs('DataSet');
    return [$rs->all];
}

sub set_data_set {
    my $self = shift;
    my $data = shift;

    my $rs = $self->_rs('DataSet')->update_or_create($data);

    return $rs->id;
}

sub new_data_set {
    my $self = shift;
    my $data = shift;

    delete $data->{id};
    my $rs = $self->_rs('DataSet')->create($data);

    return $rs->id;
}

sub get_data_set {
    my $self = shift;
    my $id = shift;

    my $rs = $self->_hrs('DataSet')->find({id => $id}) ;
    
    return $rs;
}

sub delete_data_set {
    my $self = shift;
    my $id = shift;

    my $rs = $self->_rs('DataSet')->find({id => $id})->delete;
    
    return 1;
}

no Carp;
1;
