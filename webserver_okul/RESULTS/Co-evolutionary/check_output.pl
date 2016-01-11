#!/usr/bin/perl
use strict;
use warnings;

my $progress_url = "/var/www/html/MetaPred2cs/user_$ARGV[1]/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer.html";

sub trim($)
{
    my $string = shift;
    $string =~ s/^[\t\s]+//;
    $string =~ s/[\t\s]+$//;
    $string =~ s/[\r\n]+$//; ## remove odd or bad newline values...
    return $string;
}

  my $fileIn = $ARGV[0];
    open my $fh, '<', $fileIn or die "could not open $fileIn for read\n";
    while (<$fh>) {
    chomp $_;
    my $line=trim($_);
      my @values = split('\t', $line);

    	if ($values[1] == '0.000') {
											
										system("cat $header > $progress_url");
										open(HTML,">>$progress_url");
													print HTML "Co-evolutionary Methods couldn't performed properly <br> \n";
													print HTML "Please lower the number of <b> Min_Matches </b> or higher the <b> b_value </b> and try again.. <br> \n";
									close(HTML);
									system("cat $footer >> $progress_url");
									die;
											}
}
