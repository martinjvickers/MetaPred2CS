#!/usr/bin/perl 

#use strict;
use warnings;
use CGI;
use CGI::Carp 'fatalsToBrowser';
use DBI;
use DBD::mysql;
use CGI::Response qw(:Simple);


my $upload_dir = "/var/www/webserver_okul/INPUTS";
my $tempdir = MetaPre2cs.rand(time);
my $q = new CGI;

my $first_user_input = $upload_dir ."/inputfile1.faa-".$tempdir;
my $second_user_input = $upload_dir ."/inputfile2.faa-".$tempdir;


##Input_file1
my $fl1 = $q->param("prt1_fasta");
my $upload_filehandle = $q->upload("prt1_fasta");


if (!$upload_filehandle)
{
    $fl1 = $q->param("prt1_fasta_alt");
	open(OUTFILE, ">$first_user_input") or die "Can't open inputfile1.faa: $!";
	print OUTFILE $fl1;
}
else {

open ( UPLOADFILE, ">$first_user_input" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle> )
{
    print UPLOADFILE;
}

close UPLOADFILE;

}

###Input_file2
my $fl2 = $q->param("prt2_fasta");
my $upload_filehandle2 = $q->upload("prt2_fasta");

if (!$upload_filehandle2)
{
	$fl2 = $q->param("prt2_fasta_alt");
	open(OUTFILE, "> $second_user_input") or die "Can't open inputfile2.faa: $!";
	print OUTFILE $fl2;
}

else {

open ( UPLOADFILE, ">$second_user_input" ) or die "$!";
binmode UPLOADFILE;

while ( <$upload_filehandle2> )
{
    print UPLOADFILE;
}

close UPLOADFILE;

}


#DEFINE A MySQL QUERY
chdir "$upload_dir";

my $header_check1 = qx(grep ">" $first_user_input); 

if (!$header_check1) {

system "mkdir -p /var/www/html/MetaPred2cs/input_check_$tempdir/";
                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/input_check_$tempdir/";
                my $input_check1 = "http://localhost/MetaPred2cs/input_check_$tempdir/wait_page.html";

my $progress_url1 = "/var/www/html/MetaPred2cs/input_check_$tempdir/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

        system("cat $header > $progress_url1");
        open(HTML,">>$progress_url1");
        print HTML "Your first input fasta file needs a header!<br> \n";
        print HTML 'Please check <a href="../../help_page1.html"> help page </a> to see required header format <br> ';
        close(HTML);
        system("cat $footer >> $progress_url1");
	print &Redirect("$input_check1");
        die;

	}

my $header_check2 = qx(grep ">" $second_user_input); 

if (!$header_check2) {

system "mkdir -p /var/www/html/MetaPred2cs/input_check2_$tempdir/";
                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/input_check2_$tempdir/";
                my $input_check2 = "http://localhost/MetaPred2cs/input_check2_$tempdir/wait_page.html";

my $progress_url2 = "/var/www/html/MetaPred2cs/input_check2_$tempdir/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

        system("cat $header > $progress_url2");
        open(HTML,">>$progress_url2");
        print HTML "Your second input fasta file needs a header!<br> \n";
        print HTML 'Please check <a href="../../help_page1.html"> help page </a> to see required header format <br>';
        close(HTML);
        system("cat $footer >> $progress_url2");
	print &Redirect("$input_check2");
        die;

	}

chomp (my $prA1 = qx(grep "`grep ">" $first_user_input | cut -d "|" -f 2`" id2gi.txt | cut -d "|" -f 1));

if (!$prA1) {
		system "mkdir -p /var/www/html/MetaPred2cs/input_check_$tempdir/";
                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/input_check_$tempdir/";
                my $input_check1 = "http://localhost/MetaPred2cs/input_check_$tempdir/wait_page.html";

my $progress_url1 = "/var/www/html/MetaPred2cs/input_check_$tempdir/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

        system("cat $header > $progress_url1");
        open(HTML,">>$progress_url1");
        print HTML "Header format of your first fasta file looks different than required format!<br> \n";
        print HTML 'Please check <a href="../../help_page1.html"> help page </a> to see required header format <br> ';
        close(HTML);
        system("cat $footer >> $progress_url1");
	print &Redirect("$input_check1");
        die;
        }

chomp (my $query_specie = qx(grep ">" $first_user_input | cut -d "[" -f 2 | cut -d "]" -f 1));

if (!$query_specie) {
        
system "mkdir -p /var/www/html/MetaPred2cs/query_specie_$tempdir/";
                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/query_specie_$tempdir/";
                my $query_specie = "http://localhost/MetaPred2cs/query_specie_$tempdir/wait_page.html";

my $progress_url1 = "/var/www/html/MetaPred2cs/query_specie_$tempdir/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

        system("cat $header > $progress_url1");
        open(HTML,">>$progress_url1");
        print HTML "Header format of your first fasta file looks different than required format!<br> \n";
        print HTML 'Please check <a href="../../help_page1.html"> help page </a> to see required header format <br> ';
        close(HTML);
        system("cat $footer >> $progress_url1");
	print &Redirect("$input_check1");
        die;

       }

chomp (my $prA2 = qx(grep "`grep ">" $second_user_input | cut -d "|" -f 2`" id2gi.txt | cut -d "|" -f 1));

if (!$prA2) {

		system "mkdir -p /var/www/html/MetaPred2cs/input_check2_$tempdir/";
                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/input_check2_$tempdir/";
                my $input_check2 = "http://localhost/MetaPred2cs/input_check2_$tempdir/wait_page.html";

my $progress_url2 = "/var/www/html/MetaPred2cs/input_check2_$tempdir/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

        system("cat $header > $progress_url2");
        open(HTML,">>$progress_url2");
        print HTML "Header format of your second fasta file looks different than required format!<br> \n";
        print HTML 'Please check <a href="../../help_page1.html"> help page </a> to see required header format <br> ';
        close(HTML);
        system("cat $footer >> $progress_url2");
	print &Redirect("$input_check2");
        die;
    }


my $input = $prA1."-".$prA2;
my $input_reverse = $prA2."-".$prA1;

chdir;

# MYSQL CONFIG VARIABLES
my $platform = "mysql";
my $host = "localhost";
my $database = "Precalculated_inputs";
my $tablename = "inputs_and_results";
#'my $user = "root";
my $user = "meta_user";
my $pw = 'supersecret';
my $dsn = "dbi:$platform:$database:localhost:3306";

# PERL MYSQL CONNECT()
my $connect = DBI->connect($dsn, $user, $pw);

my $query_mysql = "select distinct IDs, Class, MetaPredictor_Score FROM $tablename where IDs IN ('$input','$input_reverse')";

                my $query_handle_mysql = $connect->prepare($query_mysql);
                $query_handle_mysql->execute();
                my @data = $query_handle_mysql->fetchrow_array();
                
if (@data){
                my $Precalculated = $data[0]."\t".$data[1]."\t".$data[2];
		
		system "mkdir -p /var/www/html/MetaPred2cs/user_$tempdir/";
		system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/user_$tempdir/";
		my $wait_url = "http://localhost/MetaPred2cs/user_$tempdir/wait_page.html";

		my $progress_url = "/var/www/html/MetaPred2cs/user_$tempdir/wait_page.html";
		my $header_final = "/var/www/html/MetaPred2cs/checkmysql_header.html";
		my $footer_final = "/var/www/html/MetaPred2cs/footer_final.html";

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
		print HTML "<table border='1'><tr>
			<caption> <b> Prediction Result </b> </caption>
			<th>ID</th>
			<th>Class</th>
			<th>MetaPred2cs_Score</th></tr>";
		print HTML "<tr><td>"
			.$data[0]."</td><td>"
			.$data[1]."</td><td>"
			.$data[2]."</td></tr>";
		print HTML "</table>";
			close(HTML);
			system("cat $footer_final >> $progress_url");	
		
		print &Redirect("$wait_url");
		
			exit;

		    }else{
		
		system "cp -f /var/www/html/second_page_dnm.html /var/www/html/second_page/second_page_$tempdir.html";
                
		my $second_page = "http://localhost/second_page/second_page_$tempdir.html";

                my $progress_url = "/var/www/html/second_page/second_page_$tempdir.html";
                my $header_final = "/var/www/html/second_page_header.html";
                my $footer_final = "/var/www/html/second_page_footer.html";

			my $first_input = "inputfile1.faa-".$tempdir;
			my $second_input = "inputfile2.faa-".$tempdir;

                	system("cat $header_final > $progress_url");
                	open(HTML,">>$progress_url");
			print HTML "Fasta file of first protein sequence: $fl1 \n";
			print HTML "<input type='checkbox' name='prt1_fasta' value='$first_input' checked> <br> ";
			print HTML "Fasta file of second protein sequence: $fl2 \n";
			print HTML "<input type='checkbox' name='prt2_fasta' value='$second_input' checked> <br> ";
			close(HTML);
                        system("cat $footer_final >> $progress_url");

			print &Redirect("$second_page");

			}
