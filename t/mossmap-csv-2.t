#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use IO::File;
use IO::String;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/../ll/lib/perl5";
use lib "$Bin/lib";
use MossMap::CSV;

#use Test::DataDirs::Exporter;

# Test reading in data using mk_filtered_row_iterator

my $parser = MossMap::CSV->new;

sub drain {
    my ($iter, @rows, @row) = shift;
    push @rows, [@row] while @row = $iter->();
    return \@rows;
}

my @cases = (
    { headings => "Taxon,GR,Tetrad,Site,Year,Recorder",
      cases => [
          '6 fig GR,SJ5785,SJ58S,some where,2013,"Jones, S.P."'
              => ['6 fig GR','SJ58S','2013',["Jones, S.P."]],
          ['converting grid-ref to tetrad: SJ5785 -> SJ58S'],
          
          'tetrad,SJ57Z,SJ57Z,some where,2013,"Jones, S.P."'
              => ['tetrad','SJ57Z','2013',["Jones, S.P."]],
          [],

          'GR precision too low,SJ57,SJ57,some where,2013,"Jones, S.P."'
              => undef, 
          ['discarding as too coarse: SJ57'],

          'GR invalid,SJ5,SJ5,some where,2013,"Jones, S.P."' 
              => qr/invalid grid ref 'SJ5' has bad length \(3\)/,
          [],

          'GR precision too low,SJ,SJ,some where,2013,"Jones, S.P."'
              => undef,
          ['discarding as too coarse: SJ'],

          'GR invalid,S,S,some where,2013,"Jones, S.P."'
              => qr/invalid grid ref 'S' has bad length \(1\)/,
          [],

         'GR empty,,,some where,2013,"Jones, S.P."'
              => qr/empty grid ref/,
          [],

          'GR invalid,SJ567,SJ567,some where,2013,"Jones, S.P."'
              => qr/invalid grid ref 'SJ567' has 5 characters but is not a tetrad/,
          [],

          'GR invalid,543100,543100,some where,2013,"Jones, S.P."'
              => qr/invalid grid ref '543100'/,
          [],

          'GR invalid,5431Z,5431Z,some where,2013,"Jones, S.P."'
              => qr/invalid grid ref '5431Z'/,
          [],
          
          'recorder whitespace,SJ56Y,SJ56Y,some where,2013,"  Smith, W.   "'
              => ['recorder whitespace','SJ56Y','2013',["Smith, W."]],
          [],

          'multiple recorders,SJ56Y,SJ56Y,some where,2013,"Smith, W.; Jones, S.P."'
              => ['multiple recorders','SJ56Y','2013',["Smith, W.","Jones, S.P."]],
          [],

          'multiple recorders,SJ56Y,SJ56Y,some where,2013,"  Smith, W.  ; Jones, S.P. "'
              => ['multiple recorders','SJ56Y','2013',["Smith, W.","Jones, S.P."]],
          [],

          'multiple recorders,SJ56Y,SJ56Y,some where,2013,"  Jones, S.P. ; "'
              => ['multiple recorders','SJ56Y','2013',["Jones, S.P."]],
          [],
      ]},

    { headings => "Taxon,GR,Tetrad,Site,Year,Month,Day,Recorder",
      cases => [
          '3 fig date,SJ5785,SJ58S,some where,2013,01,14,"Jones, S.P."'
              => ['3 fig date','SJ58S','20130114',["Jones, S.P."]],
          ['converting grid-ref to tetrad: SJ5785 -> SJ58S'],
      ]},

    { headings => "Taxon,GR,Tetrad,Site,Recorder",
      cases => [
          'no date,SJ5785,SJ58S,some where,"Jones, S.P."'
              => qr/These mandatory headings are missing even after normalising the input headings: year at/,
          [],
      ]},

    { headings => "Taxon,GR,Tetrad,Year,Site,Year,Recorder",
      cases => [
          'two years,SJ57Y,SJ57Y,2013,some where,2014,"Jones, S.P."'
              => ['two years','SJ57Y',2014,["Jones, S.P."]],
          ['these headings are duplicated after normalising, '.
               'so you may not be getting the result you expect: year'],
      ]},


    { headings => "Grid-ref, tet rad ,Site ,Year,MONTH, DAY, rEcorders, extra,,TaX_on.,",
      cases => [
          'SJ58S,SJ58S,some where,2013,01,14,"Jones, S.P.",stuff,0,mangled headings,x,y,z'
              => ['mangled headings','SJ58S','20130114',["Jones, S.P."]],
          [],
      ]},

)
;

=pod
  


    "converting grid-ref to tetrad: SJ7967 -> SJ76Y",
    "converting grid-ref to tetrad: SJ5584 -> SJ58M",
    "converting grid-ref to tetrad: SK0297 -> SK09I",
    "converting grid-ref to tetrad: SJ4844 -> SJ44X",
    "converting grid-ref to tetrad: SJ5785 -> SJ58S",
    "discarding as too coarse: SJ57",
    "discarding as too coarse: SJ",
    "discarding as too coarse: SJ5",
    "discarding as undefined grid ref",
    "invalid grid ref 'SJ567' has 5 characters but is not a tetrad",

=cut


# Test mk_row_iterator
for my $case (@cases) {
    my ($headings, $row_cases) = @$case{qw(headings cases)};

    for(my $ix = 0; $ix < @$row_cases; $ix += 3) {

        my $data = [$headings, $row_cases->[$ix]];

        my $expected = $row_cases->[$ix+1];
        # Massage into the correct structure
        $expected = [$expected] if ref $expected eq 'ARRAY'; # Normal row
        $expected = [] if !defined $expected; # empty array if undef
        # $expected may also be a regexp matching the expected error

        my $expected_traces = $row_cases->[$ix+2];
        my @traces;

        $parser->trace(sub { push @traces, shift });

        my ($iter, $got);
        eval {
            $iter = $parser->mk_filtered_row_iterator($data);
            $got = drain($iter);
        };
        my $err = $@;
        if (ref $expected eq 'Regexp') {
            like $err, qr/$expected/,
                "correct exceptions thrown"
                    or note "bad case:\n", map { "  $_\n" } @$data; 
        }
        else {
            is_deeply $got, $expected, 
                "correct data read"
                    or note "bad case:\n", map { "  $_\n" } @$data; 
            
            is_deeply \@traces, $expected_traces,
                "correct traces read"
                    or note "bad traces:\n", map { "  $_\n" } @traces;
        }
    }
}


# FIXME test dupe and missing headings

done_testing;

__END__


for my $case (cases) {
    my @traces;
    $parser->trace(sub { push @traces, @_ });
    my ($name, $source) = @$case;
    my $iter = $parser->mk_filtered_row_iterator($source);
    my $iter2 = sub {
        my @ary;
        if (eval { @ary = $iter->(); 1 }) {
            @ary and return \@ary;
        }
        # Error, save it.
        my $err = $@;
        $err =~ s/ at .*//sm;
        push @traces, $err;
        return;
    };
    my $got = drain($iter2);
    # print explain $got;
    is_deeply $got, $expected_filtered,
        "reading '$name' source correctly";

    is_deeply \@traces, $expected_traces,
        "traces are correct";

    print explain \@traces;
}



__DATA__

Tetraphis pellucida,SJ7967,SJ76Y,The Quinta,2002,"Smith, J; Jones, S.P."
Hypnum cupressiforme,SJ5584,SJ58M,Oxmoor Local Nature Reserve,2013,"Jones, S.P."
Tortula muralis,SK0297,SK09I,Tintwistle,2013,"Bloggs, J."
Plagiothecium nemorale,SJ4844,SJ44X,Wych Brook area,1994,"Smith, J."
