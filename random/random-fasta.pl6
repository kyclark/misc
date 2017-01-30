#!/usr/bin/env perl6

use Bio::SeqIO;

sub MAIN (
	Str :$fasta! where *.IO.f, 
	Rat :$percent! where 0 < * < 1,
) {
	my $count = $fasta.IO.lines.grep(/^'>'/).elems;
	if $count == 0 {
		note "Found no sequences in $fasta";
		exit(1);
	}

	my $out-file = open $fasta ~ '.sub', :w;
	my @take     = (0..$count).BagHash.grab(round($count * $percent)).sort;
	my $seq-in   = Bio::SeqIO.new(format => 'fasta', file => $fasta);
	my $next     = @take.shift;
	my $i        = 0;

	while (my $seq = $seq-in.next-Seq) {
		$i++;
		#say $seq;
		#put "$i: Will take $next";
		if $i == $next {
			$out-file.print(sprintf(">%s\n%s\n", $i, $seq.seq));
			#say $seq;
			if @take {
				$next = @take.shift;
			}	
			else {
				last;
			}
		}
	}
}

sub USAGE {
    printf 
  	  "Usage:\n  %s --fasta=<File> --percent=<Double>\n" ~
	  "Percent must be between 0 and 1\n",
	  $*PROGRAM-NAME;
}
