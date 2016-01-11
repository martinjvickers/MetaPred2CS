#!/usr/bin/perl
use strict;
use warnings;


my $progress_url = "/var/www/html/MetaPred2cs/user_$ARGV[1]/wait_page.html";
my $header_final = "/var/www/html/MetaPred2cs/header_final.html";
my $footer_final = "/var/www/html/MetaPred2cs/footer_final.html";

open FH, '<', $ARGV[0] or die $!;
my $data = do {local $/; <FH>};
close FH or die $!;
my @columns = split( "\t", $data );

my $id = $columns[0];
my $class = $columns[7];
my $meta_score = $columns[8];


my $jobid = $ARGV[1];

system("cat $header_final > $progress_url");
open(HTML,">>$progress_url");
print HTML "<style>

table {
    width: 70%;
    margin-left: auto;
    margin-right: auto;
}

th {
  font-weight: bold;
  background: #CEDADA;
		text-align:center;
		}

td {
			background: #F0F0F0;
			text-align:center;
}

</style>";


print HTML "<h3_main>\n";
print HTML " <H3>Results Job ID:  <font color=\"red\">".$jobid."</font><H3><br />\n";
print HTML "  <H3>Uploaded Files</H3>\n";
print HTML "<table border='1'><tr>
																        <th>ID</th>
                        <th>Value</th></tr>";
                print HTML "<tr><td>"
                        ."Uploaded fasta file for first protein sequence"."</td><td>"
                        .$ARGV[2]."</td></tr>";
                print HTML "<tr><td>"
                        ."Uploaded fasta file for second protein sequence"."</td><td>"
                        .$ARGV[3]."</td></tr>";
																print HTML "<tr><td>"
                        ."Uploaded TUS file for query specie"."</td><td>"
                        .$ARGV[4]."</td></tr>";
                print HTML "<tr><td>"
                        ."Uploaded Ptt file for query specie"."</td><td>"
                        .$ARGV[5]."</td></tr>";

                print HTML "</table> <br>";


print HTML "  <H3>Employed Parameters for i2h & MT Methods</H3>\n";

print HTML "<table border='1'><tr>
																        <th>Param</th>
                        <th>Value</th></tr>";
															print HTML "<tr><td>"
                        ."Selected e-value for Blast Search"."</td><td>"
                        .$ARGV[6]."</td></tr>";
               print HTML "<tr><td>"
                        ."Selected b-value for Blast Search"."</td><td>"
                        .$ARGV[7]."</td></tr>";
															print HTML "<tr><td>"
                        ."Selected Limit for Min Matches"."</td><td>"
                        .$ARGV[8]."</td></tr>";
                print HTML "<tr><td>"
                        ."Selected Cut-off Value for Max Matches"."</td><td>"
                        .$ARGV[9]."</td></tr>";
																print HTML "<tr><td>"
                        ."Employed Function for Correlation Calculation"."</td><td>"
                        .$ARGV[10]."</td></tr>";
                print HTML "<tr><td>"
                        ."Employed Residue Homology Matrice"."</td><td>"
                        .$ARGV[11]."</td></tr>";
																print HTML "</table> <br>";

print HTML "  <H3>Employed Parameters for Genomics Context Methods</H3>\n";

print HTML "<table border='1'><tr>
																        <th>Param</th>
                        <th>Value</th></tr>";
                print HTML "<tr><td>"
                        ."Selected e-value for Phylogenetic Profiling Method"."</td><td>"
                        .$ARGV[12]."</td></tr>";
                print HTML "<tr><td>"
                        ."Selected Threshold for Mutual Information"."</td><td>"
                        .$ARGV[13]."</td></tr>";
																print HTML "<tr><td>"
                        ."Selected e-value for Gene Fusion Method"."</td><td>"
                        .$ARGV[14]."</td></tr>";
                print HTML "<tr><td>"
                        ."Selected Cut-off Value for Bits"."</td><td>"
                        .$ARGV[15]."</td></tr>";
																print HTML "<tr><td>"
                        ."Selected e-value for Gene Neighbourhood Method"."</td><td>"
                        .$ARGV[16]."</td></tr>";
                print HTML "<tr><td>"
                        ."Selected Value for Nucleic Acid Distance"."</td><td>"
                        .$ARGV[17]."</td></tr>";
																print HTML "<tr><td>"
                        ."Selected e-value for Gene Operon Method"."</td><td>"
                        .$ARGV[18]."</td></tr>";															
																print HTML "</table> <br>";

print HTML " <H3 style=color:#FF0000 > Result </H3> <br />\n";


print HTML "<table border='1'><tr>
																        <th>ID of Query Protein Pair</th>
																								<th>Prediction Class</th>
                        <th>Prediction Score</th></tr>";
                print HTML "<tr><td>"
                        .$id."</td><td>"
																								.$class."</td><td>"
                        .$meta_score."</td></tr>";
                print HTML "</table> <br>";

close(HTML);
system("cat $footer_final >> $progress_url");

exit;

