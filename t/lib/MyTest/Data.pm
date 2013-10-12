package MyTest::Data;
use strict;
use warnings;
use Text::CSV;
use MossMap::Model;
use JSON::PP;
use FindBin qw($Bin $Script);
use File::Spec;
use File::Path qw(mkpath rmtree);
use base 'Exporter';
use Test::Mojo;

our @EXPORT_OK = qw($temp_dir);

our $temp_dir;


sub import {
    my (undef, undef, $file) = File::Spec->splitpath($Script);

    $temp_dir = "$Bin/temp/$file";

    if (!$ENV{MOSSMAP_DB}) {
        # Use a transient SQLite database by default
        $ENV{MOSSMAP_DB} = "$temp_dir/db";
    }
    elsif ($ENV{MOSSMAP_DB} eq 'stub') {
        # Make sure we load the stub MossMap::Model class
        # preferentially, so that no database is used at all.
        unshift @INC, "$Bin/stub";
    }
    # Otherwise, some external database will be used.
    # We expect it to be empty, ready to be populated.

    rmtree $temp_dir;
    mkpath $temp_dir;
}

# A convenient source of record data which looks like data from
# a DBIx::Class query
my $json = JSON::PP->new;

sub bulk_json_sets {
    return [map { $json->decode($_) } <<SET1, <<SET2];
[["Marchantia polymorpha subsp. ruderalis",[["SJ79A",{"20130430":1}]]],["Metzgeria furcata",[["SJ79A",{"20130430":1}]]],["Metzgeria violacea",[["SJ79A",{"20130430":1}]]],["Mnium hornum",[["SJ79A",{"20130430":1}]]],["Orthotrichum affine",[["SJ79A",{"20130430":1}]]],["Orthotrichum pulchellum",[["SJ79A",{"20130430":1}]]],["Rhynchostegium confertum",[["SJ79A",{"20130430":1}]]],["Rhytidiadelphus squarrosus",[["SJ79A",{"20130430":1}]]],["Schistidium crassipilum",[["SJ79A",{"20130430":1}]]],["Syntrichia ruralis var. ruralis",[["SJ79A",{"20130430":1}]]],["Tortula muralis",[["SJ79A",{"20130430":1}]]],["Ulota bruchii",[["SJ79A",{"20130430":1}]]],["Ulota phyllantha",[["SJ79A",{"20130430":1}]]]]
SET1
[["Cratoneuron filicinum",[["SJ79A",{"20130430":1}]]],["Didymodon insulanus",[["SJ79A",{"20130430":1}]]],["Didymodon rigidulus",[["SJ79A",{"20130430":1}]]],["Didymodon tophaceus",[["SJ79A",{"20130430":1}]]],["Didymodon vinealis",[["SJ79A",{"20130430":1}]]],["Drepanocladus aduncus",[["SJ79A",{"20130430":1}]]],["Fissidens bryoides var. bryoides",[["SJ79A",{"20130430":1}]]],["Frullania dilatata",[["SJ79A",{"20130430":1}]]],["Funaria hygrometrica",[["SJ79A",{"20130430":1}]]],["Grimmia pulvinata",[["SJ79A",{"20130430":1}]]],["Hypnum cupressiforme var. cupressiforme",[["SJ79A",{"20130430":1}]]],["Kindbergia praelonga",[["SJ79A",{"20130430":1}]]],["Leptobryum pyriforme",[["SJ79A",{"20130430":1}]]],["Leptodictyum riparium",[["SJ79A",{"20130430":1}]]]]
SET2
}

sub bulk_csv_sets {
    return [<<SET1, <<SET2];
"Taxon","GR","Easting","Northing","Buffer","Precision","Monad","Tetrad","Hectad","Habitat species","Habitat site","Site","Day","Month","Year","Finder","Determiner","COLLECTION","COLLNO","Confirmer","Comments","ALTITUDE","ZeroAbund","Seen?","DateType","StartDate","EndDate","COMPILER","BULBILS","FEMALE_PRESENT","FRUITING","GEMMAE","LIT_REFERENCE"
"Marchantia polymorpha subsp. ruderalis","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Metzgeria furcata","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Metzgeria violacea","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Mnium hornum","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Orthotrichum affine","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Orthotrichum pulchellum","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Rhynchostegium confertum","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Rhytidiadelphus squarrosus","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Schistidium crassipilum","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Syntrichia ruralis var. ruralis","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Tortula muralis","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Ulota bruchii","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Ulota phyllantha","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
SET1
"Taxon","GR","Easting","Northing","Buffer","Precision","Monad","Tetrad","Hectad","Habitat species","Habitat site","Site","Day","Month","Year","Finder","Determiner","COLLECTION","COLLNO","Confirmer","Comments","ALTITUDE","ZeroAbund","Seen?","DateType","StartDate","EndDate","COMPILER","BULBILS","FEMALE_PRESENT","FRUITING","GEMMAE","LIT_REFERENCE"
"Cratoneuron filicinum","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Didymodon insulanus","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Didymodon rigidulus","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Didymodon tophaceus","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Didymodon vinealis","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Drepanocladus aduncus","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Fissidens bryoides var. bryoides","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Frullania dilatata","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Funaria hygrometrica","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Grimmia pulvinata","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Hypnum cupressiforme var. cupressiforme","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Kindbergia praelonga","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Leptobryum pyriforme","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Leptodictyum riparium","SJ7191",371500,391500,500,"1km","SJ7191","SJ79A","SJ79",,"Derelict land","Partington, N of",30,4,2013,"Callaghan, D.A.","Callaghan, D.A."
SET2
}



1;
