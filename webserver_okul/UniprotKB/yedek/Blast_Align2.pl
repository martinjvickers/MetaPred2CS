#!/usr/bin/perl
use strict;
use warnings;
use Bio::SeqIO;
use Bio::AlignIO::clustalw;


$|=1;

my $blast_input_file1 = $ARGV[0];
my $blast_input_file2 = $ARGV[1];
my $e_value = $ARGV[2];
my $b_value = $ARGV[3];
my $blast_output1 = $ARGV[4];
my $blast_output2 = $ARGV[5];
my $progress_url = $ARGV[6];
my $header = $ARGV[7];
my $footer = $ARGV[8];    

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

{
system ("blastpgp -i $blast_input_file1 -d ./DB/Uniprot_bacteria -e $e_value -b $b_value -m 8 -o Blast_output_prt1");

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

system ("blastpgp -i $blast_input_file2 -d ./DB/Uniprot_bacteria -e $e_value -b $b_value -m 8 -o Blast_output_prt2");

###FORMAT BLAST_OUTPUT
}

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence &#x2713 <br> \n";
print HTML "Parsing BLAST output.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

{

system ("tr '|' '\t' <Blast_output_prt1 > Blast_output_formatted_prt1 && rm -rf Blast_output_prt1");
system ("tr '|' '\t' <Blast_output_prt2 > Blast_output_formatted_prt2 && rm -rf Blast_output_prt2");

}

###

{

sub trim($)
{
    my $string = shift;
    $string =~ s/^[\t\s]+//;
    $string =~ s/[\t\s]+$//;
    $string =~ s/[\r\n]+$//; ## remove odd or bad newline values...
    return $string;
}

    my $fileIn1 = 'Blast_output_formatted_prt1';
    #my $OutFile = $input;
    open my $fh1, '<', $fileIn1 or die "could not open $fileIn1 for read\n";
    #open OUTFILE, ">" , $OutFile or die "$0: open $OutFile: $!";
    while (<$fh1>) {
   chomp $_;
    my $line1=trim($_);
      my @values1 = split('\t', $line1);

    						system ("fastacmd -d ./DB/Uniprot_bacteria -p protein -s $values1[6] >> myHits_prt1.fasta");
				}

				my $fileIn2 = 'Blast_output_formatted_prt2';
    #my $OutFile = $input;
    open my $fh2, '<', $fileIn2 or die "could not open $fileIn2 for read\n";
    #open OUTFILE, ">" , $OutFile or die "$0: open $OutFile: $!";
    while (<$fh2>) {
    chomp $_;
    my $line2=trim($_);
      my @values2 = split('\t', $line2);

    						system ("fastacmd -d ./DB/Uniprot_bacteria -p protein -s $values2[6] >> myHits_prt2.fasta");
						}
}

{
my %unique;

my $blast_hits   = "myHits_prt1.fasta";
my $seqio  = Bio::SeqIO->new(-file => $blast_hits, -format => "fasta");
my $outseq = Bio::SeqIO->new(-file => ">$blast_hits.unique", -format => "fasta");

while(my $seqs = $seqio->next_seq) {
  my $id  = $seqs->display_id;
  my $seq = $seqs->seq;
  unless(exists($unique{$seq})) {
    $outseq->write_seq($seqs);
    $unique{$seq} +=1;
  }
}

my %unique2;

my $blast_hits2   = "myHits_prt2.fasta";
my $seqio2  = Bio::SeqIO->new(-file => $blast_hits2, -format => "fasta");
my $outseq2 = Bio::SeqIO->new(-file => ">$blast_hits2.unique", -format => "fasta");

while(my $seqs2 = $seqio2->next_seq) {
  my $id2  = $seqs2->display_id;
  my $seq2 = $seqs2->seq;
  unless(exists($unique2{$seq2})) {
    $outseq2->write_seq($seqs2);
    $unique2{$seq2} +=1;
  }
}

}

###MSAs

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence &#x2713 <br> \n";
print HTML "Parsing BLAST output &#x2713 <br> \n";
print HTML "Performing MSA for first protein sequence.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

{
my $MSA1 = `clustalw -INFILE=myHits_prt1.fasta.unique -OUTFILE=$blast_output1 -OUTPUT=PIR`;

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence &#x2713 <br> \n";
print HTML "Parsing BLAST output &#x2713 <br> \n";
print HTML "Performing MSA for first protein sequence &#x2713 <br> \n";
print HTML "Performing MSA for second protein sequence.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

my $MSA2 = `clustalw -INFILE=myHits_prt2.fasta.unique -OUTFILE=$blast_output2 -OUTPUT=PIR`;

}

###Clean directory && Move outputs to input source
my $cmd = q(rm -rf Blast_output_formatted_prt1 myHits_prt1.fasta myHits_prt1.fasta.dnd myHits_prt1.fasta.unique Blast_output_formatted_prt2 myHits_prt2.fasta myHits_prt2.fasta.dnd myHits_prt2.fasta.unique && mv *.pir /home/altan/webserver_okul/INPUTS);

system ($cmd);



