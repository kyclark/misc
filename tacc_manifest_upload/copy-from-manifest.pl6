#!/usr/bin/env perl6

use File::Find;
use File::Temp;

my $FILES-UPLOAD = '/home1/03137/kyclark/cyverse-cli/bin/files-upload';

sub MAIN (Str $in-dir where *.IO.d) {
    my @manifest = find(dir => $in-dir, name => 'MANIFEST')
                   or die 'No MANIFEST files';
    my $tmpdir   = $*SPEC.catdir(tempdir(), $in-dir.IO.basename);
    mkdir($tmpdir) unless $tmpdir.IO.d;

    for @manifest -> $manifest {
        my $man-dir = $manifest.IO.dirname;
        for $manifest.IO.lines -> $file {
            (my $path = $file) ~~ s/^ '.' /$man-dir/;
            next unless $file.IO.f;

            my $partial = $path.subst(/^$in-dir/, '').subst(/^\//, '');
            my $tmpdest = $*SPEC.catdir($tmpdir, $partial.IO.dirname);
            mkdir($tmpdest) unless $tmpdest.IO.d;
            copy($file, $*SPEC.catfile($tmpdest, $file.IO.basename));
        }
    }

    say "Uploading $tmpdir";
    my $proc = run(«$FILES-UPLOAD -F $tmpdir kyclark/applications», :out, :err);
    say $proc.out.slurp-rest;;
    if (my @err = $proc.err.lines) {
        say "Error: {@err.join("\n")}";
    }
    say "Done.";
}
