#!/usr/bin/env perl6

use BioInfo::Parser::FASTA;
use BioInfo::IO::FileParser;

subset File of Str where *.IO.f;

sub MAIN (File :$sum-file!, File :$fasta-file!, Str :$taxa!) {
    die "$sum-file does not end with '.sum'" unless $sum-file.ends-with('.sum');
    my $tsv-file = $sum-file.subst(/'.sum' $/, '.tsv');
    die "Cannot find matching '$tsv-file'" unless $tsv-file.IO.f;
    my Str @tax-ids = get-tax-ids($tsv-file, $taxa);
    put "filter {@tax-ids.join(', ')} from file ($sum-file)";

    my $fasta   = Bio::IO::FileParser.new(
        :parser<BioInfo::Parser::FASTA>, :file($fasta-file)
    );
    my $sum-fh  = open $sum-file, :r;
    my @sum-hdr = $sum-fh.get.split("\t");

    for 1..* Z $fasta.get Z $sum-fh.lines -> ($i, $seq, $summary) {
        my %cent-info = flat @sum-hdr Z $summary.split("\t");
        dd %cent-info;
        dd $seq;
        printf "%3d: %s %s\n", $i, $seq.id, %cent-info<readID>;
        last;
    }
}

sub get-tax-ids(File $tsv-file, Str $taxa) {
    my $fh     = open $tsv-file;
    my @header = $fh.get.split("\t");
    my %tax-ids;
    for $fh.lines -> $line {
        my %rec = @header Z=> $line.split("\t");
        %tax-ids{ %rec<name> } = %rec<taxID>;
    }

    my @ids;
    for $taxa.split(/\s* ',' \s*/) -> $id {
        if $id ~~ Int {
            @ids.push($id);
        }
        else {
            if my $val = %tax-ids{ $id } {
                @ids.push($val);
            }
            else {
                note "Cannot find taxa '$id' in $tsv-file";
            }
        }
    }

    return @ids;
}
