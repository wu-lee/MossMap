#!/usr/bin/perl
use strict;
use warnings;
use File::Slurp qw(slurp);
use IO::File;

# Rewrites the CSV example data into .json files which can be imported
# into couchdb

my @files = (
    {
        inname => 'Monad Species Count',
        generate => sub { 
            my %a = @_;
            return qq({"_id":"count/$a{Monad}","monad":"$a{Monad}","count":$a{Count}}\n); 
        },
        outname => sub { 
            my %a = @_;
            return "count.$a{Monad}";
        }
    },
    {
        inname => 'Monad Species Records',
        generate => sub { 
            my %a = @_;
            return qq({"_id":"records/$a{Monad}","monad":"$a{Monad}","species":"$a{Species}"}\n); 
        },
        outname => sub { 
            my %a = @_;
            return "records.$a{Monad}";
        }
    },
);
#my $species_records = 'Monad Species Records.csv';

for my $file (@files) {
    my ($headings, @lines) = slurp "$file->{inname}.csv";
    chomp $headings;
    my @headings = split /,/, $headings;

    for(@lines) {
        chomp;
        my %data;
        @data{@headings} = split /,/;

        my $outname = $file->{outname}->(%data);
        my $fh = IO::File->new("> ../_docs/$outname.json") or die $!;
        print {$fh} $file->{generate}->(%data);
        $fh->close;
    }
}
