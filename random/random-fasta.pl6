#!/usr/bin/env perl6

use Bio::SeqIO;

subset File of Str where *.IO.f;

sub MAIN (
    File :$fasta!, 
    Str  :$out-dir=$*CWD.Str, 
    Int  :$percent is copy = 20,  
    Int  :$num=0
) {
    unless $num > 0 || $percent > 0 {
        note("Must provide either --num or --percent");
        exit(1)
    }

    mkdir($out-dir) unless $out-dir.IO.d;

    my $count = $fasta.IO.lines.grep(/^'>'/).elems;
    if $count == 0 {
        note "Found no sequences in $fasta";
        exit(1);
    }

    if $num > 0 {
        $percent = (round($num/$count, .01) * 100).Int;
    }

    unless 0 < $percent < 100 {
        note("--percent ($percent) must be between 0 and 100");
        exit(1)
    }

    my $out-file = $*SPEC.catfile($out-dir, $fasta ~ '.sub');
    my $out-fh   = open $out-file, :w;
    my $seq-in   = Bio::SeqIO.new(format => 'fasta', file => $fasta);
    my $max      = round($count * $percent / 100);
    my $took     = 0;

    while (my $seq = $seq-in.next-Seq) {
        if (1..100).pick <= $percent {
            $took++;
            $out-fh.print(sprintf(">%s\n%s\n", $took, $seq.seq));
            if $took == $max {
                last;
            }
        }
    }

    printf("Took %s into %s\n", $took, $out-file);
}

sub USAGE {
    printf 
        "Usage:\n  %s --fasta=<File> --percent=<Double>\n" ~
      "Percent must be between 0 and 100\n",
      $*PROGRAM-NAME;
}
