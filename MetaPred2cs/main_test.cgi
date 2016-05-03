#!/usr/bin/perl

#use strict;
use warnings;
use CGI;
use CGI qw/:standard/;
use CGI::Response qw(:Simple);

$| = 1;

my $tempdir = MetaPre2cs.rand(time);

my $upload_dir = "/var/www/webserver_okul/INPUTS";

system "mkdir -p /var/www/webserver_okul/INPUTS/InputPtt_$tempdir";

my $upload_dir2 = "/var/www/webserver_okul/INPUTS/InputPtt_$tempdir";

my $TUS_repository = "../../../../var/www/webserver_okul/TUSs_Repository/";
my $PTT_repository = "../../../../var/www/webserver_okul/PTT_Repository/";

my $q = new CGI;

##Input_file1

my $fl1 = $q->param("prt1_fasta");

###Input_file2
my $fl2 = $q->param("prt2_fasta");

##Input_file3

#chomp (my $GI_TUS_PTT = `grep ">" $fl1 | cut -d "|" -f 2`);

#chdir "$TUS_repository";

#chomp (my $fl3 = qx(grep -l "$GI_TUS_PTT" *));

#system ("cp $fl3 $upload_dir");

#chdir;



#my $fl3 = $q->param("tus_file");
#my $upload_filehandle3 = $q->upload("tus_file");

#if (!$upload_filehandle3)
#{
#    system "mkdir -p /var/www/html/MetaPred2cs/input_check_$tempdir/";
#                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/input_check_$tempdir/";
#                my $input_check1 = "http://localhost/MetaPred2cs/input_check_$tempdir/wait_page.html";

#my $progress_url1 = "/var/www/html/MetaPred2cs/input_check_$tempdir/wait_page.html";
#my $header       = "/var/www/html/MetaPred2cs/header.html";
#my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

#        system("cat $header > $progress_url1");
#        open(HTML,">>$progress_url1");
#        print HTML "Please upload .tus file for your query specie. <br> \n";
#        print HTML 'Please check <a href="../../help_page2.html"> help page </a> to see from where you can download .tus file for your query specie. <br> ';
#        close(HTML);
#        system("cat $footer >> $progress_url1");
#	print &Redirect("$input_check1");
#        die;
#}

#open ( UPLOADFILE, ">$upload_dir/$fl3" ) or die "$!";
#binmode UPLOADFILE;

#while ( <$upload_filehandle3> )
#{
#    print UPLOADFILE;
#}

#close UPLOADFILE;

###Input_file4

#chdir "$PTT_repository";

#chomp (my $fl4 = qx(grep -l "$GI_TUS_PTT" *));

#system ("cp $fl4 $upload_dir2");

#chdir;

#die;

#my $fl4 = $q->param("ptt_file");
#my $upload_filehandle4 = $q->upload("ptt_file");

#if (!$upload_filehandle4)
#{
   
#system "mkdir -p /var/www/html/MetaPred2cs/input_check_$tempdir/";
#                system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/input_check_$tempdir/";
#                my $input_check1 = "http://localhost/MetaPred2cs/input_check_$tempdir/wait_page.html";

#my $progress_url1 = "/var/www/html/MetaPred2cs/input_check_$tempdir/wait_page.html";
#my $header       = "/var/www/html/MetaPred2cs/header.html";
#my $footer       = "/var/www/html/MetaPred2cs/footer_error.html";

#        system("cat $header > $progress_url1");
#        open(HTML,">>$progress_url1");
#        print HTML "Please upload ptt file for your query specie. <br> \n";
#        print HTML 'Please check <a href="../../help_page2.html"> help page </a> to see from where you can download .ptt file for your query specie. <br> ';
#        close(HTML);
#        system("cat $footer >> $progress_url1");
#	print &Redirect("$input_check1");
#        die;


#}

#open ( UPLOADFILE, ">$upload_dir2/$fl4" ) or die "$!";
#binmode UPLOADFILE;

#while ( <$upload_filehandle4> )
#{
#    print UPLOADFILE;
#}

#close UPLOADFILE;
 
####POST PARAMETERS FOR BLAST & MSAs

my $e_value = $q->param("e_value"); ## 13
my $b_value = $q->param("b_value"); ## 14

####POST I2H && MT PARAMETERS
my $min_matches = $q->param("min_matches"); ## 2
my $max_matches = $q->param("max_matches") ; ## 3
my $CorCal = $q->param("CorCal"); ## 4
my $matrix = $q->param("Matrix"); ## 5

####POST PARAMETERS FOR GENOMICS PIPELINE

##PARAMETERS_For_Phylogeny_Profile_Method_PPM
my $cut_off1 = $q->param("ct1"); #default - for the joint entropy calculation ##6
my $cut_off2 = $q->param("ct2"); #default - NCBI BLASTP's E value for protein mapping to taxon
my $selected_reference_taxon_PPM = 'SelectedTaxon.properties';
##PARAMETERS_For_Gene_Fusion_Method_GFM
my $cut_off3 = $q->param("ct4"); #default - cutoff value of the all to all NCBI BLASTP's E value
my $cut_off4 = $q->param("ct3") ; #default - cutoff value of the  Bits in the ssearch34
my $selected_reference_taxon_GFM = 'SelectedTaxon.properties';
##PARAMETERS_For_Gene_Neighbor_Method_GNM
my $cut_off5 = $q->param("ct5"); #default - nucleic acids distance  used to define the neighbor genes
my $cut_off6 = $q->param("ct6"); #default - cutoff value of the all to all NCBI BLASTP's E value
my $selected_reference_taxon_GNM = 'SelectedTaxon.properties';
##PARAMETERS_For_Gene_Operon_Method_GOM
my $cut_off7 = $q->param("ct7"); #default - cutoff value of the all to all NCBI BLASTP's E value ##12

#######SET WAIT_PAGE##############


system "mkdir -p /var/www/html/MetaPred2cs/user_$tempdir/";
system "cp -f /var/www/html/MetaPred2cs/wait_page.html /var/www/html/MetaPred2cs/user_$tempdir/";
my $wait_url = "http://localhost/MetaPred2cs/user_$tempdir/wait_page.html";
 
print &Redirect("$wait_url","permanent");
#print $q->redirect('$wait_url');

#######RUN MAIN SCRIPT##############

system ("perl /usr/lib/cgi-bin/MetaPred2cs/main_wrapper_test.pl $fl1 $fl2 $min_matches $max_matches $CorCal $matrix $cut_off1 $cut_off2 $cut_off3 $cut_off4 $cut_off5 $cut_off6 $cut_off7 $e_value $b_value $tempdir $upload_dir $upload_dir2\&");

###################################


