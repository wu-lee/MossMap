# This is a stub definition of MossMap::Model
# for testing, which doesn't actually connect to a database.
package MossMap::Model;
use strict;
use warnings;
use Carp qw(croak);

my @sets;

# Make sure MossMap::Model->_schema->deploy does nothing.
sub _schema { return shift; }
sub deploy {}


sub new { return bless {}, shift }

sub _deploy {}

sub data_sets {
    return [grep { defined } @sets];
}

sub new_data_set {
    my ($self, $data) = @_;
        
    push @sets, $data;
    $data->{id} = @sets;

    $data->{created_on} = 'whatever';
    $data->{records} ||= [];

    return $data->{id};
}

sub delete_data_set {
    my ($self, $id) = @_;
    delete $sets[$id-1];
    return;
}

sub get_data_set {
    my ($self, $id) = @_;
    my $data = $sets[$id-1];
        
    return $data;
}

sub set_data_set {
    my ($self, $data) = @_;
    croak "argument must be a hashref"
        unless ref $data eq 'HASH';
    my $id = $data->{id};
    croak "argument must have an id defined"
        unless defined $id;
        
    $data->{created_on} = 'whatever';
    $data->{records} ||= [];

    $sets[$id-1] = $data;
    return;
}

1;
