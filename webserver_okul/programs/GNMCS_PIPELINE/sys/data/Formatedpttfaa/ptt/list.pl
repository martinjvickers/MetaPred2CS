#!/usr/bin/perl
use strict;
use warnings;
#$id = $input;
# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
    my $string = shift;
    $string =~ s/^[\t\s]+//;
    $string =~ s/[\t\s]+$//;
    $string =~ s/[\r\n]+$//; ## remove odd or bad newline values...
    return $string;
}

    my $fileIn = $ARGV[0];
    #my $OutFile = $input;
    open my $fh, '<', $fileIn or die "could not open $fileIn for read\n";
    #open OUTFILE, ">" , $OutFile or die "$0: open $OutFile: $!";
    while (<$fh>) {
    chomp $_;
    my $line=trim($_);
      my @values = split('\t', $line);

		system("cd $values[0] && chmod 755 * && cd ..");
}

exit;









