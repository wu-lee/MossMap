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
{"completed":["set1","whatever","SJ18Y","SJ18Z","SJ58Y","SJ68D","SJ68E","SJ68I","SJ68J","SJ68N","SJ68P","SJ68T","SJ68U","SJ68Y","SJ68Z","SJ69V","SJ78D","SJ78E","SJ79A","SJ79B","SJ79F","SJ79G","SJ79K","SJ79L","SJ79Q","SJ79R","SJ79V","SJ79W","SJ88N","SJ88P","SJ88T","SJ89B"],"taxa":["set1","whatever",["Amblystegium serpens var. serpens",[["SJ88M",{"20130215":1}]]],["Aulacomnium palustre",[["SJ86A",{"20010901":1}]]],["Barbula unguiculata",[["SJ87M",{"19930313":2}]]],["Bryum argenteum",[["SJ58F",{"20130222":1}]]],["Bryum capillare",[["SJ68Y",{"19931031":1}],["SJ77C",{"19920229":2}],["SJ78D",{"20130418":1}]]],["Bryum rubens",[["SJ58B",{"20130104":1}]]],["Calypogeia muelleriana",[["SJ57F",{"20040504":1}]]],["Campylopus introflexus",[["SJ75R",{"20130304":2}],["SJ97A",{"19951202":1}]]],["Campylopus pyriformis",[["SJ65V",{"20020905":1}]]],["Cephalozia bicuspidata",[["SE00Q",{"20100711":1}]]],["Cryphaea heteromalla",[["SJ88N",{"20130303":1}]]],["Dichodontium pellucidum",[["SJ58X",{"20130401":1}]]],["Dicranella heteromalla",[["SJ97S",{"19940806":1}]]],["Dicranella schreberiana",[["SJ97J",{"19821231":1}]]],["Dicranella varia",[["SJ68H",{"20110509":1}]]],["Encalypta streptocarpa",[["SJ98U",{"20010816":2}]]],["Fissidens fontanus",[["SJ98P",{"19121231":1}]]],["Grimmia pulvinata",[["SJ38J",{"20090206":1}]]],["Hypnum andoi",[["SJ99A",{"20010430":2}]]],["Kindbergia praelonga",[["SJ67N",{"19940716":1}],["SJ88F",{"20130325":1}]]],["Lophocolea bidentata",[["SJ68Y",{"20130411":1}]]],["Marchantia polymorpha subsp. ruderalis",[["SJ88T",{"20130310":1}]]],["Orthodontium lineare",[["SJ87L",{"19650915":2}]]],["Oxyrrhynchium hians",[["SJ88N",{"20130306":1}]]],["Pellia epiphylla",[["SJ77P",{"19920705":2}]]],["Plagiomnium affine",[["SJ57Q",{"20040619":1}]]],["Plagiothecium succulentum",[["SJ37G",{"20130414":1}]]],["Pogonatum urnigerum",[["SK07B",{"19760608":1}]]],["Pohlia nutans",[["SK07E",{"20111026":2}]]],["Rhizomnium punctatum",[["SJ28X",{"20001231":1}]]],["Rhytidiadelphus squarrosus",[["SJ86D",{"20020727":1}]]],["Syntrichia papillosa",[["SJ58B",{"20130104":1}]]],["Syntrichia ruralis var. ruralis",[["SJ58L",{"20130220":1}]]],["Tortula muralis",[["SJ45W",{"20010616":1}],["SJ68X",{"20130419":2}],["SJ68Y",{"19931031":1}]]],["Zygodon viridissimus var. viridissimus",[["SJ47X",{"20081206":1}]]]]}
SET1
{"completed":["set2","whatever","SJ18Y","SJ18Z","SJ28M","SJ47Z","SJ48V","SJ57E","SJ57J","SJ57P","SJ58A","SJ58B","SJ58F","SJ58G","SJ58H","SJ58K","SJ58L","SJ58M","SJ58Q","SJ58R","SJ58S","SJ58V","SJ58W","SJ58X","SJ58Y","SJ68A","SJ68B","SJ68C","SJ68D","SJ68E","SJ68F","SJ68G","SJ68H","SJ68I","SJ68J","SJ68K","SJ68L","SJ68M","SJ68N","SJ68P","SJ68Q","SJ68R","SJ68S","SJ68T","SJ68U","SJ68V","SJ68W","SJ68X","SJ68Y","SJ68Z","SJ69V","SJ78A","SJ78B","SJ78C","SJ78D","SJ78E","SJ79A","SJ79B","SJ79F","SJ79G","SJ79K","SJ79L","SJ79Q","SJ79R","SJ79V","SJ79W","SJ88G","SJ88N","SJ88P","SJ88T","SJ89B"],"taxa":["set2","whatever",["Aloina aloides",[["SJ66P",{"20011204":1}]]],["Amblystegium serpens var. serpens",[["SJ78E",{"20130419":1}]]],["Atrichum undulatum var. undulatum",[["SJ88Y",{"20090702":1}]]],["Aulacomnium androgynum",[["SJ88I",{"20130217":1}]]],["Barbula unguiculata",[["SJ58A",{"20130209":1}],["SJ97S",{"19940806":1}]]],["Brachythecium albicans",[["SJ28M",{"20001231":1}]]],["Brachythecium mildeanum",[["SJ68N",{"20130405":1}]]],["Brachythecium rutabulum",[["SJ58B",{"20130104":1}],["SJ97U",{"19920510":1}],["SJ99T",{"19970906":1}]]],["Bryoerythrophyllum recurvirostrum",[["SJ58G",{"20130101":1}]]],["Bryum capillare",[["SJ37C",{"20070526":1}],["SJ68T",{"20130410":1}],["SJ88S",{"20090125":1}]]],["Bryum dichotomum",[["SJ89V",{"20130420":1}]]],["Bryum rubens",[["SJ68Y",{"20130411":1}]]],["Calypogeia fissa",[["SJ58W",{"20110505":1}]]],["Calypogeia muelleriana",[["SK07E",{"20111213":1}]]],["Campylopus flexuosus",[["SJ87P",{"19641231":1}]]],["Campylopus pyriformis",[["SJ28M",{"20011031":1}]]],["Chiloscyphus polyanthos s.l.",[["SJ98R",{"19910813":1}]]],["Conocephalum conicum s.l.",[["SJ98H",{"19940430":1}]]],["Cratoneuron filicinum",[["SJ88P",{"20130313":1}]]],["Dicranella staphylina",[["SJ68T",{"20130410":1}]]],["Dicranella varia",[["SJ58S",{"20130320":1}]]],["Dicranoweisia cirrata",[["SJ58A",{"20130131":1}],["SJ58G",{"20130101":1}],["SJ68M",{"20130409":1}]]],["Dicranum bonjeanii",[["SJ56T",{"19650331":1}]]],["Dicranum scoparium",[["SJ56Z",{"20070729":1}]]],["Fissidens bryoides var. bryoides",[["SK07E",{"19911124":1}]]],["Fontinalis antipyretica var. antipyretica",[["SJ77U",{"19800930":1}]]],["Fossombronia pusilla",[["SJ58V",{"20130428":1}]]],["Funaria hygrometrica",[["SJ57J",{"20130209":1}],["SJ87N",{"20030527":1}]]],["Grimmia pulvinata",[["SJ58G",{"20130101":1}],["SJ79G",{"20050204":1}]]],["Homalothecium sericeum",[["SJ88P",{"20090513":1}]]],["Hypnum cupressiforme",[["SJ57G",{"20040504":1}]]],["Kindbergia praelonga",[["SJ57P",{"20130406":1}],["SJ77C",{"20040220":1}],["SJ78D",{"20130418":1}]]],["Leptodictyum riparium",[["SJ68T",{"20130410":1}]]],["Lophocolea bidentata",[["SJ67L",{"20001014":1}]]],["Lunularia cruciata",[["SJ58X",{"20130401":1}]]],["Mnium hornum",[["SJ57U",{"20110521":1}],["SJ68Y",{"20130411":1}],["SJ88F",{"20130325":1}]]],["Orthotrichum lyellii",[["SJ58W",{"20110510":1}]]],["Orthotrichum stramineum",[["SJ68C",{"20130402":1}]]],["Oxyrrhynchium hians",[["SJ68T",{"20130411":1}]]],["Oxyrrhynchium pumilum",[["SJ64J",{"19950228":1}]]],["Physcomitrium sphaericum",[["SJ96H",{"20031003":1}],["SJ97K",{"19940923":1}]]],["Plagiomnium undulatum",[["SJ98G",{"19951202":1}]]],["Plagiothecium succulentum",[["SJ37L",{"20130414":1}]]],["Plagiothecium undulatum",[["SJ57K",{"20070406":1}],["SJ99R",{"20020817":1}]]],["Polytrichastrum formosum",[["SJ79K",{"19960413":1}]]],["Polytrichum juniperinum",[["SJ77P",{"20010721":1}]]],["Polytrichum piliferum",[["SJ78L",{"19920718":1}]]],["Pseudoscleropodium purum",[["SJ28M",{"20011031":1}]]],["Pseudotaxiphyllum elegans",[["SJ88G",{"19951231":1}]]],["Racomitrium aciculare",[["SJ98T",{"20010816":1}]]],["Rhizomnium punctatum",[["SJ57L",{"19791231":1}]]],["Rhynchostegium confertum",[["SJ58B",{"20130104":1}]]],["Rhytidiadelphus squarrosus",[["SJ46B",{"20050218":1}],["SJ88F",{"20060204":1}],["SJ97S",{"19940612":1}]]],["Schistidium apocarpum s.l.",[["SJ98H",{"19840430":1}]]],["Sphagnum palustre",[["SJ77K",{"19760430":1}]]],["Sphagnum papillosum",[["SJ56Z",{"20101201":1}],["SJ65V",{"20020905":1}]]],["Syntrichia latifolia",[["SJ46A",{"20050218":1}]]],["Tetraphis pellucida",[["SJ58B",{"20130104":1}]]],["Tortula freibergii",[["SJ58L",{"20081231":1}],["SJ58Q",{"20081231":1}],["SJ67X",{"20081231":1}],["SJ78P",{"20090503":1}]]],["Tortula muralis",[["SJ58V",{"20130428":1}]]],["Tortula truncata",[["SJ57L",{"19990422":1}]]],["Ulota phyllantha",[["SJ98H",{"20050531":1}]]]]}
SET2
}

sub bulk_csv_sets {
    return [<<SET1, <<SET2];
"Taxon","GR","Easting","Northing","Buffer","Precision","Monad","Tetrad","Hectad","Habitat species","Habitat site","Site","Day","Month","Year","Finder","Determiner","COLLECTION","COLLNO","Confirmer","Comments","ALTITUDE","ZeroAbund","Seen?","DateType","StartDate","EndDate","COMPILER","BULBILS","FEMALE_PRESENT","FRUITING","GEMMAE","LIT_REFERENCE"
"Amblystegium serpens var. serpens","SJ8584",385500,384500,500,"1km","SJ8584","SJ88M","SJ88",,,"Stanley Green",15,2,2013,"Lowell, J.","Lowell, J.",,,,,,,,"Day",15/02/2013,,,,,,,
"Aulacomnium palustre","SJ8061",380500,361500,500,"1km","SJ8061","SJ86A","SJ86",,,"Brookhouse Moss",1,9,2001,"Hodgetts, N.G.","Unknown",,,,"NVC survey for EN, subcontracted by Alex Lockton.",,,,"Day",01/09/2001,01/09/2001,"Hodgetts, N.G.",,,,,
"Barbula unguiculata","SJ8475",384500,375500,500,"1km","SJ8475","SJ87M","SJ87",,,"Alderley Park",13,3,1993,"British Bryological Society - North West Group","Unknown",,,,,100,,,"Day",13/03/1993,13/03/1993,,,,"Y",,
"Barbula unguiculata","SJ8475",384500,375500,500,"1km","SJ8475","SJ87M","SJ87",,,"Alderley Park",13,3,1993,"British Bryological Society - North West Group","Unknown",,,,,100,,,"Day",13/03/1993,13/03/1993,,,,"Y",,
"Bryum argenteum","SJ5381",353500,381500,500,"1km","SJ5381","SJ58F","SJ58",,,"Halton Cemetery and Town Park",22,2,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",22/02/2013,,,,,,,
"Bryum capillare","SJ682871",368250,387150,50,"100m","SJ6887","SJ68Y","SJ68",,,"The Dingle,Lymm",31,10,1993,"Holness, J.H.","Unknown",,,,,25,,,"Month",01/10/1993,31/10/1993,,,,,,
"Bryum capillare","SJ7075",370500,375500,500,"1km","SJ7075","SJ77C","SJ77",,,"Plumley Nature Reserve",29,2,1992,"British Bryological Society - North West Group","Unknown",,,,,30,,,"Day",29/02/1992,29/02/1992,,,,,,
"Bryum capillare","SJ7075",370500,375500,500,"1km","SJ7075","SJ77C","SJ77",,,"Plumley Nature Reserve",29,2,1992,"British Bryological Society - North West Group","Unknown",,,,,30,,,"Day",29/02/1992,29/02/1992,,,,,,
"Bryum capillare","SJ7087",370500,387500,500,"1km","SJ7087","SJ78D","SJ78",,"Canal","Bridgewater Canal, Oughtrington",18,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Bryum rubens","SJ5083",383500,387500,500,"1km","SJ5083","SJ58B","SJ58",,"Urban","Runcorn (nr bridge)",4,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/01/2013,,,,,,,
"Calliergonella cuspidata","SJ38",335000,385000,5000,"10km","NA","NA","SJ38",,,"No site name available",31,12,1988,"Unknown","Unknown",,,,,,,,"Before Year",31/12/1899,31/12/1988,,,,,,
"Calypogeia azurea","SK09",405000,395000,5000,"10km","NA","NA","SK09",,,"No site name available",31,12,1989,"Newton, M.E.","Unknown",,,,,,,,"Year Range",01/01/1960,31/12/1989,,,,,,
"Calypogeia azurea","SK09",405000,395000,5000,"10km","NA","NA","SK09",,,"No site name available",31,12,1989,"Newton, M.E.","Unknown",,,,,,,,"Year Range",01/01/1960,31/12/1989,,,,,,
"Calypogeia muelleriana","SJ537719",353750,371950,50,"100m","SJ5371","SJ57F","SJ57",,,"Delamere Forest",4,5,2004,"Smith, A.V.","Unknown",,,,"AO7 :HAB -",80,,,"Day",04/05/2004,04/05/2004,"Smith, A.V.",,,,,
"Campylopus introflexus","SJ56",355000,365000,5000,"10km","NA","NA","SJ56",,,"No site name available",31,12,1982,"Unknown","Unknown",,,,,,,,"Year",01/01/1982,31/12/1982,,,,,,
"Campylopus introflexus","SJ7652",376500,352500,500,"1km","SJ7652","SJ75R","SJ75",,"Churchyard and village","Barthomley",4,3,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/03/2013,,,,,,,
"Campylopus introflexus","SJ7652",376500,352500,500,"1km","SJ7652","SJ75R","SJ75",,"Churchyard and village","Barthomley",4,3,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/03/2013,,,,,,,
"Campylopus introflexus","SJ9070",390500,370500,500,"1km","SJ9070","SJ97A","SJ97",,,"Danes Moss",2,12,1995,"British Bryological Society - North West Group","Unknown",,,,,,,,"Day",02/12/1995,02/12/1995,,,,"Y",,
"Campylopus pyriformis","SJ6950",369500,350500,500,"1km","SJ6950","SJ65V","SJ65",,,"Wybunbury Moss",5,9,2002,"Hodgetts, N.G.; Lockton, A.J.","Unknown",,,,"Survey for Alex Lockton on behalf of EN.",,,,"Day",05/09/2002,05/09/2002,"Hodgetts, N.G.",,,,,
"Cephalozia bicuspidata","SE00Q",407000,401000,1000,"2km","NA","SE00Q","SE00",,"Moorland with gritstone crags","Crowden Great Brook, Longdendale",11,7,2010,"Blockeel, T.L.","Unknown",,,,,,,,"Day",11/07/2010,11/07/2010,"Blockeel, T.L.",,,,,
"Ceratodon purpureus","SJ46",345000,365000,5000,"10km","NA","NA","SJ46",,,"No site name available",31,12,1982,"Unknown","Unknown",,,,,,,,"Year",01/01/1982,31/12/1982,,,,,,
"Cryphaea heteromalla","SJ8586",385500,386500,500,"1km","SJ8586","SJ88N","SJ88",,,"Cheadle Royal",3,3,2013,"Lowell, J.","Lowell, J.",,,,,,,,"Day",03/03/2013,,,,,,,
"Dichodontium flavescens","SJ68",365000,385000,5000,"10km","NA","NA","SJ68",,,"Hillcliffe,wd below","#VALUE!","#VALUE!",1834,"Wilson, W.","Hill, M.O.","BM",,,,,,,"Year","01/01/1834","31/12/1834",,,,,,
"Dichodontium pellucidum","SJ5985",359500,385500,500,"1km","SJ5985","SJ58X","SJ59",,"Canal","Bridgewater Canal, Higher Walton",1,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",,,,,,,,
"Dicranella heteromalla","SJ46",345000,365000,5000,"10km","NA","NA","SJ46",,,"No site name available",31,12,1982,"Unknown","Unknown",,,,,,,,"Year",01/01/1982,31/12/1982,,,,,,
"Dicranella heteromalla","SJ46",345000,365000,5000,"10km","NA","NA","SJ46",,,"No site name available",31,12,1982,"Unknown","Unknown",,,,,,,,"Year",01/01/1982,31/12/1982,,,,,,
"Dicranella heteromalla","SJ97",395000,375000,5000,"10km","NA","NA","SJ97",,,"Macclesfield Forest",31,12,1964,"Birks, H.J.B.","Unknown",,,,,365,,,"Month",01/12/1964,31/12/1964,,,,,,
"Dicranella heteromalla","SJ970740",397050,374050,50,"100m","SJ9774","SJ97S","SJ97",,,"Lamaload Reservoir",6,8,1994,"Smith, A.V.","Unknown",,,,"occasional :HAB -",300,,,"Day",06/08/1994,06/08/1994,"Smith, A.V.",,,,,
"Dicranella schreberiana","SJ920780",392050,378050,50,"100m","SJ9278","SJ97J","SJ97",,,"Middlewood Way",31,12,1982,"Crundall, M.L.","Unknown",,,,"B to W :HAB -",0,,,"Year",01/01/1982,31/12/1982,"Smith, A.V.",,,,,
"Dicranella varia","SJ6284",362500,384500,500,"1km","SJ6284","SJ68H","SJ68",,,"The Dingle",9,5,2011,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",09/05/2011,,,,,,,
"Didymodon fallax","SJ28",325000,385000,5000,"10km","NA","NA","SJ28",,,"No site name available",31,12,1991,"Unknown","Unknown",,,,,,,,"Before Year",31/12/1899,31/12/1991,,,,,,
"Encalypta streptocarpa","SJ9688",396500,388500,500,"1km","SJ9688","SJ98U","SJ98",,,"Marple",16,8,2001,"Lowell, J.","Unknown",,,,,,,,"Day",16/08/2001,16/08/2001,"Smith, A.V.",,,,,
"Encalypta streptocarpa","SJ9688",396500,388500,500,"1km","SJ9688","SJ98U","SJ98",,,"Marple",16,8,2001,"Lowell, J.","Unknown",,,,,,,,"Day",16/08/2001,16/08/2001,"Smith, A.V.",,,,,
"Fissidens fontanus","SJ9588",395500,388500,500,"1km","SJ9588","SJ98P","SJ98",,,"Marple",31,12,1912,"Wilson, J.C.","Unknown","PVT",,,,,,,"Month",01/12/1912,31/12/1912,,,,,,
"Grimmia pulvinata","SJ3389",333500,389500,500,"1km","SJ3389","SJ38J","SJ38","Town centre",,"Birkenhead Hamilton Square and surrounds",6,2,2009,"Callaghan, D.A.","Unknown",,,,,20,,,"Day",06/02/2009,06/02/2009,"Hanson, P.",,,,,
"Hypnum andoi","SJ9091",390500,391500,500,"1km","SJ9091","SJ99A","SJ99",,,"Reddish Vale",30,4,2001,"Smith, A.V.","Unknown",,,,"rare :HAB -",,,,"Day",30/04/2001,30/04/2001,"Smith, A.V.",,,,,
"Hypnum andoi","SJ9091",390500,391500,500,"1km","SJ9091","SJ99A","SJ99",,,"Reddish Vale",30,4,2001,"Smith, A.V.","Unknown",,,,"rare :HAB -",,,,"Day",30/04/2001,30/04/2001,"Smith, A.V.",,,,,
"Kindbergia praelonga","SJ6576",365500,376500,500,"1km","SJ6576","SJ67N","SJ67",,,"Marbury Country Park",16,7,1994,"British Bryological Society - North West Group","Unknown",,,,,30,,,"Day",16/07/1994,16/07/1994,,,,,,
"Kindbergia praelonga","SJ8380",383500,380500,500,"1km","SJ8380","SJ88F","SJ88",,,"Lindow Common (S)",25,3,2013,"Lowell, J.","Lowell, J.",,,,,,,,,,,,,,,,
"Lepidozia reptans","SJ27",325000,375000,5000,"10km","NA","NA","SJ27",,,"No site name available",31,12,1989,"Unknown","Unknown",,,,,,,,"Before Year",31/12/1899,31/12/1989,,,,,,
"Lophocolea bidentata","SJ6886",368500,386500,500,"1km","SJ6886","SJ68Y","SJ68",,"Woodland, lake and sandstone outcrops","Lymm Dam",11,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Marchantia polymorpha subsp. ruderalis","SJ56",355000,365000,5000,"10km","NA","NA","SJ56","roadside",,"near Tarporley",31,5,1982,"Fisk, R.J.","Long, D.G.","BBSUK",,,"as alpestris",,,,"Month",01/05/1982,31/05/1982,"Long, D.G.",,,,,
"Marchantia polymorpha subsp. ruderalis","SJ8687",386500,387500,500,"1km","SJ8687","SJ88T","SJ88",,,"Cheadle(S)",10,3,2013,"Lowell, J.","Lowell, J.",,,,,,,,"Day",10/03/2013,,,,,,,
"Orthodontium gracile","SJ57",355000,375000,5000,"10km","NA","NA","SJ57",,,"Frodsham","#VALUE!","#VALUE!",1833,"Unknown","Unknown","NMW",,,"Frodsham. cfr. dehisced and undehisced. NMW.",,,,"Year","01/01/1833","31/12/1833","Porley, R.D.",,,"Y",,
"Orthodontium gracile","SJ57",355000,375000,5000,"10km","NA","NA","SJ57",,,"Frodsham","#VALUE!","#VALUE!",1833,"Unknown","Unknown","NMW",,,"Frodsham. cfr. dehisced and undehisced. NMW.",,,,"Year","01/01/1833","31/12/1833","Porley, R.D.",,,"Y",,
"Orthodontium lineare","SJ8572",385500,372500,500,"1km","SJ8572","SJ87L","SJ87",,,"Redes Mere",15,9,1965,"Birks, H.J.B.","Unknown",,,,,,,,"Day",15/09/1965,15/09/1965,,,,,,
"Orthodontium lineare","SJ8572",385500,372500,500,"1km","SJ8572","SJ87L","SJ87",,,"Redes Mere",15,9,1965,"Birks, H.J.B.","Unknown",,,,,,,,"Day",15/09/1965,15/09/1965,,,,,,
"Oxyrrhynchium hians","SJ8587",385500,387500,500,"1km","SJ8587","SJ88N","SJ88",,,"Bruntwood Hall",6,3,2013,"Lowell, J.","Lowell, J.",,,,,,,,"Day",06/03/2013,,,,,,,
"Pellia epiphylla","SJ7578",375500,378500,500,"1km","SJ7578","SJ77P","SJ77",,,"Knutsford Moor",5,7,1992,"Hodgetts, N.G.","Unknown",,,,,,,,"Day",05/07/1992,05/07/1992,"Hodgetts, N.G.",,,,,
"Pellia epiphylla","SJ7578",375500,378500,500,"1km","SJ7578","SJ77P","SJ77",,,"Knutsford Moor",5,7,1992,"Hodgetts, N.G.","Unknown",,,,,,,,"Day",05/07/1992,05/07/1992,"Hodgetts, N.G.",,,,,
"Plagiomnium affine","SJ5671",356500,371500,500,"1km","SJ5671","SJ57Q","SJ57",,,"Hart Hill",19,6,2004,"North Western Naturalists Union","Unknown",,,,,75,,,"Day",19/06/2004,19/06/2004,"Smith, A.V.",,,,,
"Plagiothecium succulentum","SJ3372",333500,372500,500,"1km","SJ3372","SJ37G","SJ37",,"Farmland","Shotwick Hall, nr.",14,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Pogonatum urnigerum","SK0173",401500,373500,500,"1km","SK0173","SK07B","SK07",,,"Goyt Valley",8,6,1976,"British Bryological Society meeting","Unknown",,,,,,,,"Day",08/06/1976,08/06/1976,,,,,,
"Pohlia nutans","SK07E",401000,379000,1000,"2km","NA","SK07E","SK07",,"Deciduous woodland","Hillbridge Wood NR, Goyt Valley",26,10,2011,"Blockeel, T.L.; Hodgson, A.J.","Unknown",,,,,,,,"Day",26/10/2011,26/10/2011,"Blockeel, T.L.",,,,,
"Pohlia nutans","SK07E",401000,379000,1000,"2km","NA","SK07E","SK07",,"Deciduous woodland","Hillbridge Wood NR, Goyt Valley",26,10,2011,"Blockeel, T.L.; Hodgson, A.J.","Unknown",,,,,,,,"Day",26/10/2011,26/10/2011,"Blockeel, T.L.",,,,,
"Polytrichastrum formosum","SJ55",355000,355000,5000,"10km","NA","NA","SJ55",,,"Peckforton Hills",10,4,1976,"British Bryological Society meeting","Unknown",,,,,,,,"Day",10/04/1976,10/04/1976,,,,,,
"Polytrichum piliferum","SJ56",355000,365000,5000,"10km","NA","NA","SJ56",,,"Oakmere",18,9,1988,"Newton, M.E.","Unknown",,,,,,,,"Day",18/09/1988,18/09/1988,,,,,,
"Polytrichum piliferum","SJ97",395000,375000,5000,"10km","NA","NA","SJ97",,,"Macclesfield",31,12,1974,"Foster, W.D.","Unknown",,,,,,,,"Year",01/01/1974,31/12/1974,,,,,,
"Rhizomnium punctatum","SJ284840",328450,384050,50,"100m","SJ2884","SJ28X","SJ28",,,"Barnston Dale",31,12,2000,"Johnson, L.","Unknown",,,,,,,,"Year",01/01/2000,31/12/2000,"Smith, A.V.",,,,,
"Rhytidiadelphus squarrosus","SJ8067",380500,367500,500,"1km","SJ8067","SJ86D","SJ86",,,"Swettenham Meadows",27,7,2002,"Smith, A.V.","Unknown",,,,,,,,"Day",27/07/2002,27/07/2002,"Smith, A.V.",,,,,
"Rhytidiadelphus squarrosus","SJ96",395000,365000,5000,"10km","NA","NA","SJ96",,,"Wincle,R Dane nr",9,4,1976,"Pitkin, P.H.","Unknown",,,,,,,,"Day",09/04/1976,09/04/1976,,,,,,
"Rhytidiadelphus squarrosus","SJ96",395000,365000,5000,"10km","NA","NA","SJ96",,,"Wincle,R Dane nr",9,4,1976,"Pitkin, P.H.","Unknown",,,,,,,,"Day",09/04/1976,09/04/1976,,,,,,
"Schistidium apocarpum s.l.","SJ64",365000,345000,5000,"10km","NA","NA","SJ64",,,"No site name available",31,12,1991,"Unknown","Unknown",,,,,,,,"Year Range",01/01/1950,31/12/1991,,,,,,
"Scorpidium scorpioides","SJ29",325000,395000,5000,"10km","NA","NA","SJ29",,,"No site name available",31,12,1921,"Unknown","Unknown",,,,,,,,"Before Year",31/12/1899,31/12/1921,,,,,,
"Syntrichia papillosa","SJ510831",391500,390500,500,"1km","SJ5183","SJ58B","SJ58","Ash trunk","Churchyard","All Saints Church (Runcorn)",4,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/01/2013,,,,,,,
"Syntrichia ruralis var. ruralis","SJ5482",354500,382500,500,"1km","SJ5482","SJ58L","SJ58",,,"Bridgewater Canal and Phoenix Park",20,2,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",20/02/2013,,,,,,,
"Tetraplodon mnioides","SJ57",355000,375000,5000,"10km","NA","NA","SJ57",,,"Delamere Forest",31,12,1932,"Unknown","Unknown",,,,,,,,"Before Year",31/12/1899,31/12/1932,,,,,,
"Tortula muralis","SJ4952",349500,352500,500,"1km","SJ4952","SJ45W","SJ45",,,"Bickerton Hill",16,6,2001,"Smith, A.V.","Unknown",,,,,,,,"Day",16/06/2001,16/06/2001,"Smith, A.V.",,,,,
"Tortula muralis","SJ68",365000,385000,5000,"10km","NA","NA","SJ68",,,"Warrington",31,12,1978,"Foster, W.D.","Unknown",,,,,,,,"Year",01/01/1978,31/12/1978,,,,,,
"Tortula muralis","SJ68",365000,385000,5000,"10km","NA","NA","SJ68",,,"Warrington",31,12,1978,"Foster, W.D.","Unknown",,,,,,,,"Year",01/01/1978,31/12/1978,,,,,,
"Tortula muralis","SJ682871",368250,387150,50,"100m","SJ6887","SJ68Y","SJ68",,,"The Dingle,Lymm",31,10,1993,"Holness, J.H.","Unknown",,,,,25,,,"Month",01/10/1993,31/10/1993,,,,,,
"Tortula muralis","SJ699841",369950,384150,50,"100m","SJ6984","SJ68X","SJ68",,"Carpark","St John's Church, High Legh",19,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Tortula muralis","SJ699841",369950,384150,50,"100m","SJ6984","SJ68X","SJ68",,"Carpark","St John's Church, High Legh",19,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Zygodon viridissimus var. viridissimus","SJ4975",349500,375500,500,"1km","SJ4975","SJ47X","SJ47",,,"Helsby Hill SBI",6,12,2008,"North Western Naturalists Union","Unknown",,,,,,,,"Day",06/12/2008,06/12/2008,"Hanson, P.",,,,"Y",
SET1
"Taxon","GR","Easting","Northing","Buffer","Precision","Monad","Tetrad","Hectad","Habitat species","Habitat site","Site","Day","Month","Year","Finder","Determiner","COLLECTION","COLLNO","Confirmer","Comments","ALTITUDE","ZeroAbund","Seen?","DateType","StartDate","EndDate","COMPILER","BULBILS","FEMALE_PRESENT","FRUITING","GEMMAE","LIT_REFERENCE"
"Aloina aloides","SJ656680",365650,368050,50,"100m","SJ6568","SJ66P","SJ66",,,"Winsford, Weaver Navigation",4,12,2001,"Hodgetts, N.G.","Unknown",,,,"T. cernua survey for Plantlife.",,,,"Day",04/12/2001,04/12/2001,"Hodgetts, N.G.",,,"Y",,
"Amblystegium serpens var. serpens","SJ7089",370500,389500,500,"1km","SJ7089","SJ78E","SJ78",,"Churchyard","St Werburgh's Church (newer church), Warburton",19,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Aneura pinguis","SJ55",355000,355000,5000,"10km","NA","NA","SJ55",,,"No site name available",31,12,1989,"Unknown","Unknown",,,,,,,,"Year Range",01/01/1950,31/12/1989,,,,,,
"Atrichum undulatum var. undulatum","SJ88Y",389000,387000,1000,"2km","NA","SJ88Y","SJ88",,,"Bramhall & carr woods",2,7,2009,"Lowell, J.","Unknown",,,,,,,,"Day",02/07/2009,02/07/2009,"Hanson, P.",,,,,
"Aulacomnium androgynum","SJ8387",383500,387500,500,"1km","SJ8387","SJ88I","SJ88",,,"Peel Hall",17,2,2013,"Lowell, J.","Lowell, J.",,,,,,,,"Day",17/02/2013,,,,,,,
"Barbilophozia attenuata","SJ55",355000,355000,5000,"10km","NA","NA","SJ55",,,"Peckforton Hills",10,4,1976,"British Bryological Society meeting","Unknown",,,,,,,,"Day",10/04/1976,10/04/1976,,,,,,
"Barbula unguiculata","SJ5180",351500,380500,500,"1km","SJ5180","SJ58A","SJ58",,"Urban","The Heath Business Park",9,2,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",09/02/2013,,,,,,,
"Barbula unguiculata","SJ9775",397500,375500,500,"1km","SJ9775","SJ97S","SJ97",,,"Lamaload Reservoir",6,8,1994,"Smith, A.V.","Unknown",,,,,300,,,"Day",06/08/1994,06/08/1994,,,,,,
"Brachythecium albicans","SJ251856",325150,385650,50,"100m","SJ2585","SJ28M","SJ28",,,"Irby Quarry",31,12,2000,"Johnson, L.","Unknown",,,,,,,,"Year",01/01/2000,31/12/2000,"Smith, A.V.",,,,,
"Brachythecium mildeanum","SJ6587",365500,387500,500,"1km","SJ6587","SJ68N","SJ68",,,"Woolston Eyes",5,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Brachythecium rutabulum","SJ510831",391500,390500,500,"1km","SJ5183","SJ58B","SJ58",,"Churchyard","All Saints Church (Runcorn)",4,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/01/2013,,,,,,,
"Brachythecium rutabulum","SJ66",365000,365000,5000,"10km","NA","NA","SJ66",,,"Ash Brook+Vale Royal",10,4,1976,"British Bryological Society meeting","Unknown",,,,,,,,"Day",10/04/1976,10/04/1976,,,,,,
"Brachythecium rutabulum","SJ9678",396500,378500,500,"1km","SJ9678","SJ97U","SJ97",,,"Harrop Wood",10,5,1992,"Smith, A.V.","Unknown",,,,,250,,,"Day",10/05/1992,10/05/1992,,,,"Y",,
"Brachythecium rutabulum","SJ9797",397500,397500,500,"1km","SJ9797","SJ99T","SJ99",,,"Eastwood Nature Reserve",6,9,1997,"North Western Naturalists Union","Unknown",,,,"abundant :HAB -",,,,"Day",06/09/1997,06/09/1997,"Smith, A.V.",,,"Y",,
"Brachythecium rutabulum","SK07",405000,375000,5000,"10km","NA","NA","SK07",,,"Taxal",31,10,1979,"Foster, W.D.","Unknown",,,,,120,,,"Month",01/10/1979,31/10/1979,,,,,,
"Bryoerythrophyllum recurvirostrum","SJ5283",385500,384500,500,"1km","SJ5283","SJ58G","SJ58",,"Woodland and grassland","Wigg Island",1,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",01/01/2013,,,,,,,
"Bryum capillare","SJ303754",330350,375450,50,"100m","SJ3075","SJ37C","SJ37",,,"Ness Gardens",26,5,2007,"Hanson, P.","Unknown",,,,,30,,,"Day",26/05/2007,26/05/2007,"Hanson, P.",,,"Y",,
"Bryum capillare","SJ6787",367500,387500,500,"1km","SJ6787","SJ68T","SJ68",,"Ponds and urban","Meadow View Fisheries and surround",10,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Bryum capillare","SJ88S",387000,385000,1000,"2km","NA","SJ88S","SJ88",,,"Clarement Rd etc",25,1,2009,"Lowell, J.","Unknown",,,,,,,,"Day",25/01/2009,25/01/2009,"Hanson, P.",,,,,
"Bryum dichotomum","SJ8890",388500,390500,500,"1km","SJ8890","SJ89V","SJ89",,,"Stockport Chestergate",20,4,2013,"Lowell, J.","Lowell, J.",,,,,,,,,,,,,,,,
"Bryum rubens","SJ6886",368500,386500,500,"1km","SJ6886","SJ68Y","SJ68",,"Woodland, lake and sandstone outcrops","Lymm Dam",11,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Bryum rubens","SJ74",375000,345000,5000,"10km","NA","NA","SJ74",,,"No site name available",31,12,1985,"Unknown","Unknown",,,,,,,,"Year",01/01/1985,31/12/1985,,,,,,
"Calypogeia fissa","SJ5983",359500,383500,500,"1km","SJ5983","SJ58W","SJ58",,,"Row's Wood",5,5,2011,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",05/05/2011,,,,,,,
"Calypogeia muelleriana","SK0079",400500,379500,500,"1km","SK0079","SK07E","SK07",,"mixed woodland","Park Wood, Goyt Valley",13,12,2011,"Blockeel, T.L.","Unknown",,,,,,,,"Day",13/12/2011,13/12/2011,"Blockeel, T.L.",,,,,
"Campylopus flexuosus","SJ855780",385550,378050,50,"100m","SJ8578","SJ87P","SJ87",,,"Alderley Edge",31,12,1964,"Birks, H.J.B.","Unknown",,,,,185,,,"Month",01/12/1964,31/12/1964,,,,,,
"Campylopus pyriformis","SJ245855",324550,385550,50,"100m","SJ2485","SJ28M","SJ28",,,"Thurstaston Common",31,10,2001,"North Western Naturalists Union","Unknown",,,,"wet area by farm :HAB -",,,,"Month",01/10/2001,31/10/2001,"Smith, A.V.",,,,,
"Chiloscyphus polyanthos s.l.","SJ960830",396050,383050,50,"100m","SJ9683","SJ98R","SJ98",,,"Elmershurst Wood",13,8,1991,"Smith, A.V.","Unknown",,,,,0,,,"Day",13/08/1991,13/08/1991,"Smith, A.V.",,,,,
"Conocephalum conicum s.l.","SJ930850",393050,385050,50,"100m","SJ9385","SJ98H","SJ98",,,"Norbury Hollow",30,4,1994,"Smith, A.V.","Unknown",,,,"frequent :HAB -",125,,,"Day",30/04/1994,30/04/1994,"Smith, A.V.",,,,,
"Cratoneuron filicinum","SJ8588",385500,388500,500,"1km","SJ8588","SJ88P","SJ88",,,"Cheadle(W)",13,3,2013,"Lowell, J.","Lowell, J.",,,,,,,,"Day",13/03/2013,,,,,,,
"Dicranella heteromalla","SJ64",365000,345000,5000,"10km","NA","NA","SJ64",,,"No site name available",31,12,1991,"Unknown","Unknown",,,,,,,,"Year Range",01/01/1950,31/12/1991,,,,,,
"Dicranella staphylina","SJ6787",367500,387500,500,"1km","SJ6787","SJ68T","SJ68",,"Ponds and urban","Meadow View Fisheries and surround",10,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Dicranella varia","SJ5785",357500,385500,500,"1km","SJ5785","SJ58S","SJ58",,,"Moore Nature Reserve",20,3,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",20/03/2013,,,,,,,
"Dicranoweisia cirrata","SJ5081",350500,381500,500,"1km","SJ5081","SJ58A","SJ58",,"Woodland, parkland and rocky outcrops","Runcorn Hill Local Nature Reserve",31,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",31/01/2013,,,,,,,
"Dicranoweisia cirrata","SJ5283",385500,384500,500,"1km","SJ5283","SJ58G","SJ58",,"Woodland and grassland","Wigg Island",1,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",01/01/2013,,,,,,,
"Dicranoweisia cirrata","SJ6485",364500,385500,500,"1km","SJ6485","SJ68M","SJ68",,,"Grappenhall Wood and adjacent stream",9,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Dicranum bonjeanii","SJ5767",357500,367500,500,"1km","SJ5767","SJ56T","SJ56",,,"Oak Mere",31,3,1965,"Birks, H.J.B.","Unknown",,,,,60,,,"Month",01/03/1965,31/03/1965,,,,,,
"Dicranum scoparium","SJ595688",359550,368850,50,"100m","SJ5968","SJ56Z","SJ56","Conifer plantation and lowland bog",,"Shemmy Moss",29,7,2007,"Callaghan, D.A.","Unknown",,,,,70,,,"Day",29/07/2007,29/07/2007,"Hanson, P.",,,,,
"Fissidens bryoides var. bryoides","SJ68",365000,385000,5000,"10km","NA","NA","SJ68",,,"Lymm",31,12,1978,"Foster, W.D.","Unknown",,,,,,,,"Year",01/01/1978,31/12/1978,,,,,,
"Fissidens bryoides var. bryoides","SK000790",400050,379050,50,"100m","SK0079","SK07E","SK07",,,"Park Wood",24,11,1991,"Newton, M.E.","Unknown",,,,"occasional :HAB -",0,,,"Day",24/11/1991,24/11/1991,"Smith, A.V.",,,,,
"Fissidens fontanus","SJ65",365000,355000,5000,"10km","NA","NA","SJ65",,,"No site name available",31,12,1987,"Fisk, R.J.","Unknown",,,,,,,,"Year",01/01/1987,31/12/1987,,,,,,
"Fontinalis antipyretica var. antipyretica","SJ7678",376500,378500,500,"1km","SJ7678","SJ77U","SJ77",,,"Booths Mere",30,9,1980,"NCC England Field Unit","Unknown",,,,,,,,"Day",30/09/1980,30/09/1980,,,,,,
"Fossombronia pusilla","SJ5881",358500,381500,500,"1km","SJ5881","SJ58V","SJ58","Arable","Arable and woodland","Newton Cross",28,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Frullania tamarisci","SJ57",355000,375000,5000,"10km","NA","NA","SJ57",,,"Delamere Forest",31,12,1932,"Unknown","Unknown",,,,,,,,"Before Year",31/12/1899,31/12/1932,,,,,,
"Funaria hygrometrica","SJ5279",352500,379500,500,"1km","SJ5279","SJ57J","SJ57",,,"Clifton and River Weaver",9,2,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",09/02/2013,,,,,,,
"Funaria hygrometrica","SJ8476",384500,376500,500,"1km","SJ8476","SJ87N","SJ87",,,"Alderley Park",27,5,2003,"Smith, A.V.","Unknown",,,,":HAB - bare ground",,,,"Day",27/05/2003,27/05/2003,"Smith, A.V.",,,,,
"Grimmia pulvinata","SJ5283",385500,384500,500,"1km","SJ5283","SJ58G","SJ58",,"Woodland and grassland","Wigg Island",1,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",01/01/2013,,,,,,,
"Grimmia pulvinata","SJ7292",372500,392500,500,"1km","SJ7292","SJ79G","SJ79",,,"Vicarage Gardens - Urmston",4,2,2005,"North Western Naturalists Union","Unknown",,,,,,,,"Day",04/02/2005,04/02/2005,"Smith, A.V.",,,,,
"Homalothecium sericeum","SJ88P",385000,389000,1000,"2km","NA","SJ88P","SJ88",,,"Gatley",13,5,2009,"Lowell, J.","Unknown",,,,,,,,"Day",13/05/2009,13/05/2009,"Hanson, P.",,,,,
"Hygrohypnum luridum","SJ65",365000,355000,5000,"10km","NA","NA","SJ65",,,"No site name available",31,12,1987,"Fisk, R.J.","Unknown",,,,,,,,"Year",01/01/1987,31/12/1987,,,,,,
"Hypnum cupressiforme","SJ538721",353850,372150,50,"100m","SJ5372","SJ57G","SJ57",,,"Delamere Forest",4,5,2004,"Smith, A.V.","Unknown",,,,"AO6 :HAB -",80,,,"Day",04/05/2004,04/05/2004,"Smith, A.V.",,,,,
"Kindbergia praelonga","SJ5578",355500,378500,500,"1km","SJ5578","SJ57P","SJ57",,"Churchyard","St Peter's Church, Aston-by-Sutton",6,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Kindbergia praelonga","SJ7075",370500,375500,500,"1km","SJ7075","SJ77C","SJ77",,,"Plumley lime beds",20,2,2004,"North Western Naturalists Union","Unknown",,,,,,,,"Day",20/02/2004,20/02/2004,"Smith, A.V.",,,,,
"Kindbergia praelonga","SJ7087",370500,387500,500,"1km","SJ7087","SJ78D","SJ78",,"Broad-leaved woodland","Helsdale Wood",18,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Leptodictyum riparium","SJ6787",367500,387500,500,"1km","SJ6787","SJ68T","SJ68",,"Ponds and urban","Meadow View Fisheries and surround",10,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Leptodontium flexifolium","SJ56",355000,365000,5000,"10km","NA","NA","SJ56",,,"No site name available",31,12,1991,"Fisk, R.J.","Unknown",,,,,,,,"Year Range",01/01/1986,31/12/1991,,,,,,
"Leucobryum glaucum","SJ55",355000,355000,5000,"10km","NA","NA","SJ55",,,"Peckforton Hills",10,4,1976,"British Bryological Society meeting","Unknown",,,,,,,,"Day",10/04/1976,10/04/1976,,,,,,
"Lophocolea bidentata","SJ28",325000,385000,5000,"10km","NA","NA","SJ28",,,"No site name available",31,12,1989,"Unknown","Unknown","LIV",,,,,,,"Before Year",31/12/1899,31/12/1989,,,,,,
"Lophocolea bidentata","SJ6572",365500,372500,500,"1km","SJ6572","SJ67L","SJ67",,,"Clough Wood",14,10,2000,"North Western Naturalists Union","Unknown",,,,"frequent :HAB -",,,,"Day",14/10/2000,14/10/2000,"Smith, A.V.",,,"Y",,
"Lophocolea bidentata","SJ96",395000,365000,5000,"10km","NA","NA","SJ96",,,"Wincle,R Dane nr",9,4,1976,"Pitkin, P.H.","Unknown",,,,,,,,"Day",09/04/1976,09/04/1976,,,,,,
"Lunularia cruciata","SJ5985",359500,385500,500,"1km","SJ5985","SJ58X","SJ58",,"Churchyard and adjacent burial field","St John's Church, Higher Walton",1,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",,,,,,,,
"Mnium hornum","SJ5778",357500,378500,500,"1km","SJ5778","SJ57U","SJ57",,,"Bird's Wood",21,5,2011,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",21/05/2011,,,,,,,
"Mnium hornum","SJ66",365000,365000,5000,"10km","NA","NA","SJ66",,,"Ash Brook+Vale Royal",10,4,1976,"British Bryological Society meeting","Unknown",,,,,,,,"Day",10/04/1976,10/04/1976,,,,,,
"Mnium hornum","SJ6886",368500,386500,500,"1km","SJ6886","SJ68Y","SJ68",,"Churchyard","St Mary's Church, Lymm",11,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Mnium hornum","SJ8281",382500,381500,500,"1km","SJ8281","SJ88F","SJ88",,,"Lindow Moss",25,3,2013,"Lowell, J.","Lowell, J.",,,,,,,,,,,,,,,,
"Orthodontium lineare","SJ96",395000,365000,5000,"10km","NA","NA","SJ96",,,"Wincle,R Dane nr",9,4,1976,"Pitkin, P.H.","Unknown",,,,,,,,"Day",09/04/1976,09/04/1976,,,,,,
"Orthotrichum lyellii","SJ5908883957",359088.5,383957.5,0.5,"1m","SJ5983","SJ58W","SJ58","On trunk of oak in woodland",,"Row's Wood",10,5,2011,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",10/05/2011,,,,,,,
"Orthotrichum stramineum","SJ6084",360500,384500,500,"1km","SJ6084","SJ68C","SJ68",,"Reservoir","Appleton Reservoir",2,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Oxyrrhynchium hians","SJ6786",367500,386500,500,"1km","SJ6786","SJ68T","SJ68",,"Woodland, lake and sandstone outcrops","Lymm Dam",11,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Oxyrrhynchium pumilum","SJ6248",362500,348500,500,"1km","SJ6248","SJ64J","SJ64",,,"Sound Common",28,2,1995,"Griffiths, J.","Unknown",,,,,19,,,"Month",01/02/1995,28/02/1995,"Smith, A.V.",,,,,
"Physcomitrium sphaericum","SJ927657",392750,365750,50,"100m","SJ9265","SJ96H","SJ96",,,"Bosley Reservoir",3,10,2003,"Hodgetts, N.G.","Unknown",,,,"Wet mud on more or less vertical banks of inflow stream, with Pseudephemerum nitidum, Physcomitrella patens, and a variety of vascular plants. Quite abundant",,,,"Day",03/10/2003,03/10/2003,"Hodgetts, N.G.",,,,,
"Physcomitrium sphaericum","SJ945715",394550,371550,50,"100m","SJ9471","SJ97K","SJ97",,,"Langley, Bottoms Reservoir",23,9,1994,"Anon","Unknown",,,,"Data in e-mail from A.V. Smith, 10 Jan 2003",,,,"Day",23/09/1994,23/09/1994,"Hodgetts, N.G.",,,,,
"Plagiomnium affine","SJ45",345000,355000,5000,"10km","NA","NA","SJ45",,,"No site name available",31,12,1988,"Unknown","Unknown",,,,,,,,"Year Range",01/01/1950,31/12/1988,,,,,,
"Plagiomnium undulatum","SJ930820",393050,382050,50,"100m","SJ9382","SJ98G","SJ98",,,"Dane's Moss",2,12,1995,"North Western Naturalists Union","Unknown",,,,"frequent :HAB -",30,,,"Day",02/12/1995,02/12/1995,"Smith, A.V.",,,,,
"Plagiothecium succulentum","SJ3472",334500,372500,500,"1km","SJ3472","SJ37L","SJ37",,"Woodland, laneside and stream","Shotwick Dale",14,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Plagiothecium undulatum","SJ542714",354250,371450,50,"100m","SJ5471","SJ57K","SJ57",,,"Delamere Forest",6,4,2007,"Hanson, P.","Unknown",,,,,30,,,"Day",06/04/2007,06/04/2007,"Hanson, P.",,,,,
"Plagiothecium undulatum","SJ9693",396500,393500,500,"1km","SJ9693","SJ99R","SJ99",,,"Werneth Low",17,8,2002,"Lowell, J.","Unknown",,,,,,,,"Day",17/08/2002,17/08/2002,"Smith, A.V.",,,,,
"Polytrichastrum formosum","SJ740910",374050,391050,50,"100m","SJ7491","SJ79K","SJ79",,,"Carrington Moss",13,4,1996,"Smith, A.V.","Unknown",,,,"abundant :HAB -",20,,,"Day",13/04/1996,13/04/1996,"Smith, A.V.",,,,,
"Polytrichum juniperinum","SJ7478",374500,378500,500,"1km","SJ7478","SJ77P","SJ77",,,"Knutsford Heath",21,7,2001,"Smith, A.V.","Unknown",,,,,,,,"Day",21/07/2001,21/07/2001,"Smith, A.V.",,,,,
"Polytrichum piliferum","SJ7483",374500,383500,500,"1km","SJ7483","SJ78L","SJ78",,,"Rostherne churchyard",18,7,1992,"British Bryological Society - North West Group","Unknown",,,,,30,,,"Day",18/07/1992,18/07/1992,,,,,,
"Pseudoscleropodium purum","SJ245855",324550,385550,50,"100m","SJ2485","SJ28M","SJ28",,,"Thurstaston Common, Old Heath",31,10,2001,"North Western Naturalists Union","Unknown",,,,,,,,"Month",01/10/2001,31/10/2001,"Smith, A.V.",,,,,
"Pseudotaxiphyllum elegans","SJ88G",383000,383000,1000,"2km","NA","SJ88G","SJ88",,,"No site name available",31,12,1995,"Lowell, J.","Unknown",,,,,,,,"Year Range",01/01/1994,31/12/1995,,,,,,
"Racomitrium aciculare","SJ9687",396500,387500,500,"1km","SJ9687","SJ98T","SJ98",,,"Marple",16,8,2001,"Lowell, J.","Unknown",,,,,,,,"Day",16/08/2001,16/08/2001,"Smith, A.V.",,,,,
"Rhizomnium punctatum","SJ57L",355000,373000,1000,"2km","NA","SJ57L","SJ57",,,"Hatch Mere",31,12,1979,"Wigginton, M.J.","Unknown",,,,,,,,"Year",01/01/1979,31/12/1979,,,,,,
"Rhynchostegium confertum","SJ5082",350500,382500,500,"1km","SJ5082","SJ58B","SJ58",,"Woodland and rocky outcrops","Runcorn Hill Local Nature Reserve",4,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/01/2013,,,,,,,
"Rhytidiadelphus squarrosus","SJ4162",341500,362500,500,"1km","SJ4162","SJ46B","SJ46",,,"Eccleston",18,2,2005,"North Western Naturalists Union","Unknown",,,,": HABITAT - walls and rockfaces",,,,"Day",18/02/2005,18/02/2005,"Smith, A.V.",,,,,
"Rhytidiadelphus squarrosus","SJ8280",382500,380500,500,"1km","SJ8280","SJ88F","SJ88",,,"Saltersley Moss CWT NR",4,2,2006,"North Western Naturalists Union","Unknown",,,,,,,,"Day",04/02/2006,04/02/2006,"Smith, A.V.",,,,,
"Rhytidiadelphus squarrosus","SJ970750",397050,375050,50,"100m","SJ9775","SJ97S","SJ97",,,"Lamaload",12,6,1994,"Hind, S.","Unknown",,,,,0,,,"Day",12/06/1994,12/06/1994,"Smith, A.V.",,,,,
"Schistidium apocarpum s.l.","SJ9385",393500,385500,500,"1km","SJ9385","SJ98H","SJ98",,,"Norbury Hollow",30,4,1984,"Smith, A.V.","Unknown",,,,,125,,,"Day",30/04/1984,30/04/1984,,,,,,
"Sphagnum palustre","SJ7470",374500,370500,500,"1km","SJ7470","SJ77K","SJ77",,,"Rudheath",30,4,1976,"Perry, A.R.","Unknown",,,,,,,,"Month",01/04/1976,30/04/1976,,,,,,
"Sphagnum papillosum","SJ595697",359550,369750,50,"100m","SJ5969","SJ56Z","SJ56",,"Bog","Brackenhurst Bog, near Delamere",1,12,2010,"Diack, I.","Unknown",,,,,,,,"Day",01/12/2010,01/12/2010,"Hill, M.O.",,,,,
"Sphagnum papillosum","SJ6950",369500,350500,500,"1km","SJ6950","SJ65V","SJ65",,,"Wybunbury Moss",5,9,2002,"Hodgetts, N.G.; Lockton, A.J.","Unknown",,,,"Survey for Alex Lockton on behalf of EN.",,,,"Day",05/09/2002,05/09/2002,"Hodgetts, N.G.",,,,,
"Syntrichia latifolia","SJ4161",341500,361500,500,"1km","SJ4161","SJ46A","SJ46",,,"Crook of Dee",18,2,2005,"North Western Naturalists Union","Unknown",,,,": HABITAT - Wood by river",,,,"Day",18/02/2005,18/02/2005,"Smith, A.V.",,,,,
"Tetraphis pellucida","SJ5082",350500,382500,500,"1km","SJ5082","SJ58B","SJ58",,"Woodland and rocky outcrops","Runcorn Hill Local Nature Reserve",4,1,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,"Day",04/01/2013,,,,,,,
"Tortula freibergii","SJ558826",355850,382650,50,"100m","SJ5582","SJ58L","SJ58","Along canal edge",,"Trent & Mersey Canal",31,12,2008,"Callaghan, D.A.","Unknown",,,,,,,,"Year",01/01/2008,31/12/2008,"Hanson, P.",,,,,
"Tortula freibergii","SJ568801",356850,380150,50,"100m","SJ5680","SJ58Q","SJ58","Along canal edge",,"Trent & Mersey Canal",31,12,2008,"Callaghan, D.A.","Unknown",,,,,,,,"Year",01/01/2008,31/12/2008,"Hanson, P.",,,,,
"Tortula freibergii","SJ684745",368450,374550,50,"100m","SJ6874","SJ67X","SJ67","Along canal edge",,"Trent & Mersey Canal",31,12,2008,"Callaghan, D.A.","Unknown",,,,,,,,"Year",01/01/2008,31/12/2008,"Hanson, P.",,,,,
"Tortula freibergii","SJ7588",375500,388500,500,"1km","SJ7588","SJ78P","SJ78",,,"Bridgewater canal",3,5,2009,"Callaghan, D.A.; Wilcox, M.","Unknown",,,,,,,,"Day",03/05/2009,03/05/2009,"Hanson, P.",,,,,
"Tortula muralis","SJ593804",359350,380450,50,"100m","SJ5980","SJ58V","SJ58",,"Amenity grassland and trees","Lewis Carroll's Birthplace",28,4,2013,"Callaghan, D.A.","Callaghan, D.A.",,,,,,,,,,,,,,,,
"Tortula truncata","SJ57L",355000,373000,1000,"2km","NA","SJ57L","SJ57",,,"Hatchmere",22,4,1999,"Newton, M.E.","Unknown",,,,,,,,"Day",22/04/1999,22/04/1999,"Smith, A.V.",,,,,
"Ulota phyllantha","SJ936844",393650,384450,50,"100m","SJ9384","SJ98H","SJ98",,,"Princes Wood",31,5,2005,"Smith, A.V.","Unknown",,,,": HABITAT - On sycamore",140,,,"Month",01/05/2005,31/05/2005,"Smith, A.V.",,,,,
SET2
}

sub bulk_csv_completions {
    return [<<SET1, <<SET2];
Tetrad
SJ79B
SJ79G
SJ79L
SJ79R
SJ79W
SJ89B
SJ69V
SJ79A
SJ79F
SJ79K
SJ79Q
SJ79V
SJ18Z
SJ68E
SJ68J
SJ68P
SJ68U
SJ68Z
SJ78E
SJ88P
SJ18Y
SJ58Y
SJ68D
SJ68I
SJ68N
SJ68T
SJ68Y
SJ78D
SJ88N
SJ88T
SET1
Tetrad
SJ79B
SJ79G
SJ79L
SJ79R
SJ79W
SJ89B
SJ69V
SJ79A
SJ79F
SJ79K
SJ79Q
SJ79V
SJ18Z
SJ68E
SJ68J
SJ68P
SJ68U
SJ68Z
SJ78E
SJ88P
SJ18Y
SJ58Y
SJ68D
SJ68I
SJ68N
SJ68T
SJ68Y
SJ78D
SJ88N
SJ88T
SJ28M
SJ58H
SJ58M
SJ58S
SJ58X
SJ68C
SJ68H
SJ68M
SJ68S
SJ68X
SJ78C
SJ58B
SJ58G
SJ58L
SJ58R
SJ58W
SJ68B
SJ68G
SJ68L
SJ68R
SJ68W
SJ78B
SJ88G
SJ48V
SJ58A
SJ58F
SJ58K
SJ58Q
SJ58V
SJ68A
SJ68F
SJ68K
SJ68Q
SJ68V
SJ78A
SJ47Z
SJ57E
SJ57J
SJ57P
SET2
}


1;
