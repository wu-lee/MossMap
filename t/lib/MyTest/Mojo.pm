package MyTest::Mojo;
use strict;
use warnings;
use base 'Test::Mojo';


sub new {
    my $self = shift->SUPER::new(@_);

    # Don't hide internal exceptions, show them on STDERR
    $self->app->hook(around_dispatch => sub {
                         my ($next, $c) = @_;
                         return if eval { $next->(); 1 };
                         warn $@;
                         die $@;
                     });

    return $self;
};



# Helper for collapsing  created_on fields to something we  can use in
# test comparisons.
sub my_json_is {
    my $self = shift;
    my ($p, $data) = ref $_[0] ? ('', shift) : (shift, shift);
    my $desc = shift || qq{exact match for JSON Pointer "$p"};
    my $json = $self->tx->res->json($p);
    $json = [$json]
        if ref \$json eq 'SCALAR';
    $self->date2whatever($json);
    return $self->_test('is_deeply', $json, $data, $desc);
}

my $date_rx = qr/^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d$/;
sub date2whatever {
    my ($self, $json) = @_;

    # A bit of a hack - try to remove dates wherever they may be
    if (ref $json eq 'ARRAY') {
        $_ =~ s/$date_rx/whatever/
            for grep { defined && !ref } @$json;
        $_->{created_on} =~ s/$date_rx/whatever/
            for grep { defined && ref eq 'HASH' } @$json;
    }
    elsif (ref $json eq 'HASH') {
        $self->date2whatever($_)
            for grep { defined } values %$json;
    }
    return $json;
}


1;
