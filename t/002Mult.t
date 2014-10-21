######################################################################
# Test suite for Archive::Tar::Wrapper
# by Mike Schilli <cpan@perlmeister.com>
######################################################################

use warnings;
use strict;
use Log::Log4perl qw(:easy);
use File::Path;
use File::Temp qw(tempfile);

my $TARDIR = "data";
$TARDIR = "t/$TARDIR" unless -d $TARDIR;
my $TMPDIR = "$TARDIR/tmp";

use Test::More tests => 5;
BEGIN { use_ok('Archive::Tar::Wrapper::IPC::Cmd') };

rmdir $TMPDIR if -d $TMPDIR;
mkdir $TMPDIR or die "Cannot mkdir $TMPDIR";
END { rmtree $TMPDIR }

my $arch = Archive::Tar::Wrapper::IPC::Cmd->new(tmpdir => $TMPDIR);

ok($arch->read("$TARDIR/foo.tgz"), "opening compressed tarfile");
ok($arch->read("$TARDIR/bar.tar"), "opening uncompressed");

my $elements = $arch->list_all();
my $got = join " ", sort map { $_->[0] } @$elements;
is($got, "001Basic.t bar/bar.dat bar/foo.dat", "file check");

# Iterators
$arch->list_reset();
my @elements = ();
while(my $entry = $arch->list_next()) {
    push @elements, $entry->[0];
}
$got = join " ", sort @elements;
is($got, "001Basic.t bar/bar.dat bar/foo.dat", "file check via iterator");
