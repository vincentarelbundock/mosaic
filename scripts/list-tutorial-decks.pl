use strict;
use warnings;

my %slugs;

for my $path (@ARGV) {
    open my $file, "<", $path or die "cannot read $path: $!\n";
    local $/;
    my $source = <$file>;
    close $file;

    while (
        $source =~ /
            \#slideshow\(
            \s*calepin\.elements\.gallery,
            \s*"([^"]+)",
            \s*(\d+)
        /gx
    ) {
        $slugs{$1} = 1 if $2 > 1;
    }
}

print "$_\n" for sort keys %slugs;
