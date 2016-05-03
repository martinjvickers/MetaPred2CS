#!/usr/bin/perl
use Bio::SeqIO;
use strict;
use warnings;

####
#######SHOW SUBMIT PAGE#############

my $progress_url = "/var/www/html/MetaPred2cs/user_$ARGV[15]/wait_page.html";
my $header       = "/var/www/html/MetaPred2cs/header.html";
my $footer       = "/var/www/html/MetaPred2cs/footer.html";

###################################

my $GNMCS_PIPELINE_workdir_copy = qx(cp -r /var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir /var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]);  ##only for run, will be removed at the end of run.
my $i2h_workdir_copy = qx(cp -r /var/www/webserver_okul/programs/i2h_package /var/www/webserver_okul/programs/i2h_package.$ARGV[15]);
my $blastdir_copy = qx(mkdir -p /var/www/webserver_okul/UniprotKB/user_$ARGV[15]);
	system "cp -f /var/www/webserver_okul/UniprotKB/Blast_Align2.pl /var/www/webserver_okul/UniprotKB/user_$ARGV[15]/";
my $BLAST_output_copy = qx(mkdir -p /var/www/webserver_okul/INPUTS/blast_out_$ARGV[15]);

####################DIRECTORIES######################################################
my $GNMCS_PIPELINE_workdir_clean = "/var/www/webserver_okul/programs/GNMCS_PIPELINE";
my $GNMCS_temporary_workdir = "/var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]";
my $i2h_temporary_workdir = "/var/www/webserver_okul/programs/i2h_package.$ARGV[15]";
my $BLAST_temporary_workdir = "/var/www/webserver_okul/UniprotKB/user_$ARGV[15]";
my $BLAST_output = "/var/www/webserver_okul/INPUTS/blast_out_$ARGV[15]";
system ("chmod 0777 $GNMCS_temporary_workdir");
my $i2h_workdir = "/var/www/webserver_okul/programs/i2h_package";
my $Results_Genomics = "/var/www/webserver_okul/RESULTS/Genomics";
my $Results_Coevolutionary = "/var/www/webserver_okul/RESULTS/Co-evolutionary";
my $GFM_OUTPUT = "/var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]/Result/GFM";
my $PPM_OUTPUT = "/var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]/Result/PPM";
my $GNM_OUTPUT = "/var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]/Result/GNM";
my $GOM_OUTPUT = "/var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]/Result/GOM";
my $GI2ID_index = "/var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]/AlltoAllBlastPTableOut/seedDir";
my $input_source = "/var/www/webserver_okul/INPUTS";
my $SVM_workdir = "/var/www/webserver_okul/programs/libsvm-3.17";
my $SVM_OUTPUT = "/var/www/webserver_okul/RESULTS/SVM";
my $TUS_repository = "../../../../var/www/webserver_okul/TUSs_Repository/";
my $PTT_repository = "../../../../var/www/webserver_okul/PTT_Repository/";

#my $BLASTDB = "/var/www/webserver_okul/UniprotKB"; ##13.5GB-uniprot-bacteria

#####################################################################################

##Input_file3

chdir "$ARGV[16]";

chomp (my $GI_TUS_PTT = `grep ">" $ARGV[0] | cut -d "|" -f 2`);

chdir;

chdir "$TUS_repository";

chomp (my $fl3 = qx(grep -l "$GI_TUS_PTT" *));

system ("cp $fl3 $ARGV[16]");

chdir;

###Input_file4

chdir "$PTT_repository";

chomp (my $fl4 = qx(grep -l "$GI_TUS_PTT" *));

system ("cp $fl4 $ARGV[17]");

chdir;

#wait_page
system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

###CHECK MYSQL DATABASE FOR PRE-CALCULATED QUERIES
chdir "$input_source";

chomp (my $prA1 = qx(grep "`grep ">" $ARGV[0] | cut -d "|" -f 2`" id2gi.txt | cut -d "|" -f 1));

chomp (my $prA2 = qx(grep "`grep ">" $ARGV[1] | cut -d "|" -f 2`" id2gi.txt | cut -d "|" -f 1));

chomp (my $query_specie = qx(grep ">" $ARGV[0] | cut -d "[" -f 2 | cut -d "]" -f 1));

##Prepare inputs for i2h&MT
my $prt1 = $prA1.".pir"; ###burdaki isimler direk olarak blast inputuna bagli olarak degismeli!!!
my $prt2 = $prA2.".pir";
chdir;

###GNMCS_PIPELINE_Parameters###############
##START_Parameters&Input_files
my $ARG1 = '../sys'; # secimli degil
my $ARG2 = '1'; #secimli olabilir tekrar bi goz at ???
#my $ARG3 = \n; # secimli degil
my $input_faa = "input_$ARGV[15].faa";
my $input_ptt = "InputPtt_$ARGV[15]";
my $Ptt_file_format = 'no'; ##NCBI_standard_format
my $RNA_Evolutonary_distance_file_16S = '../sys/mix/dist.mat'; # secimli olabilir
my $name_of_seed_taxon = 'seed'; # secimli degil
my $ARG4 = 'no'; # secimli degil
my $ARG5 = 'yes';
my $ARG6 = 'yes';
my $ARG7 = 'yes';
my $ARG8 = 'yes';
my $ARG9 = 'no'; # secimli degil
##PARAMETERS_For_Phylogeny_Profile_Method_PPM
my $selected_reference_taxon_PPM = 'SelectedTaxon.properties';
##PARAMETERS_For_Gene_Fusion_Method_GFM
my $selected_reference_taxon_GFM = 'SelectedTaxon.properties';
##PARAMETERS_For_Gene_Neighbor_Method_GNM
my $selected_reference_taxon_GNM = 'SelectedTaxon.properties';
##PARAMETERS_For_Gene_Operon_Method_GOM
my $selected_reference_taxon_GOM = 'SelectedTaxon.properties';
########################################################################
#############CONFIRMATION##################
my $omit_alltoallBLAST = 'no'; ## bu secimli degil
my $confrm_parameters = 'yes';
my $start_calculation = 'yes';
########################################################################

##BLAST&&MSAS 

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");


chdir "$input_source";

system ("cat $ARGV[0] $ARGV[1] > input_$ARGV[15].faa && mv $ARGV[0] $ARGV[1] $BLAST_temporary_workdir");

chdir;

#####BLAST&&MSAs SECTION###

chdir "$BLAST_temporary_workdir";

system ("perl Blast_Align2.pl $ARGV[0] $ARGV[1] $ARGV[13] $ARGV[14] $prt1 $prt2 $progress_url $header $footer $BLAST_output");

chdir; 

#################Distribution of prepared input files to related directories#####
chdir "$input_source";

my $sys = qx(cp $input_faa $fl3 /var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15] && cp -r $input_ptt /var/www/webserver_okul/programs/GNMCS_PIPELINE/workDir.$ARGV[15]);

chdir ;

chdir "$BLAST_output";
system ("cp $prt1 $prt2 $i2h_temporary_workdir");
chdir;

#########################CO-EVOLUTIONAR_PIPELINE#####################################

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence &#x2713 <br> \n";
print HTML "Parsin BLAST output &#x2713 <br> \n";
print HTML "Performing MSA for first protein sequence &#x2713 <br> \n";
print HTML "Performing MSA for second protein sequence &#x2713 <br> \n";
print HTML "Running Co-evolutionary Methods.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

chdir "$i2h_temporary_workdir";

##komut=./alnpirs2corr.sh   $values[0].pir  $values[1].pir 11  25  rankorr Maxhom_GCG.metric i2h_MT_results.$ARGV[15]

my $co_evo_pipeline = qx(./alnpirs2corr.sh $prt1 $prt2 $ARGV[2] $ARGV[3] $ARGV[4] $ARGV[5] i2h_MT_results.$ARGV[15] && cp i2h_MT_results.$ARGV[15] $Results_Coevolutionary);

chdir;

chdir "$Results_Coevolutionary";

my $new_format = qx(perl -p -i -e 's/\t\t   /\t/g' i2h_MT_results.$ARGV[15] && perl -p -i -e 's/\t   /\t/g' i2h_MT_results.$ARGV[15] && perl cut_i2h_results.pl i2h_MT_results.$ARGV[15] > i2h_MT_results.$ARGV[15].1 && sort -u i2h_MT_results.$ARGV[15].1 -o i2h_MT_results.$ARGV[15].final_sorted);
my $check_output = qx(perl check_output.pl i2h_MT_results.$ARGV[15].final_sorted $ARGV[15]);
my $prepare_index = qx(perl index.pl i2h_MT_results.$ARGV[15].final_sorted > index.$ARGV[15] && mv index.$ARGV[15] i2h_MT_results.$ARGV[15].final_sorted $Results_Genomics && rm -rf i2h_MT_results.$ARGV[15].1 i2h_MT_results.$ARGV[15]);

chdir;


##########################################################################
####################GNMCS_PIPELINE########################################
##########################################################################

###writing parameter file in gnmx pipeline workdir && run genomics pipeline

chdir "$GNMCS_temporary_workdir";

system ("perl select_reference_genome_list.pl '$query_specie' > SelectedTaxon.properties");

system ("chmod 0777 lib && chmod 755 lib/InPrePPI.jar && chmod 755 SelectedTaxon.properties");

my $filename = "GNMX_PIPELINE_PARAMETERS";
open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
print $fh "$ARG1\n$ARG2\n\n$input_faa\n$input_ptt\n$Ptt_file_format\n$fl3\n$RNA_Evolutonary_distance_file_16S\n$name_of_seed_taxon\n$ARG4\n$ARG5\n$ARG6\n$ARG7\n$ARG8\n$ARG9\n$ARGV[6]\n$ARGV[7]\n$selected_reference_taxon_PPM\n$ARGV[8]\n$ARGV[9]\n$selected_reference_taxon_GFM\n$ARGV[10]\n$ARGV[11]\n$selected_reference_taxon_GNM\n$ARGV[12]\n$selected_reference_taxon_GOM\n$omit_alltoallBLAST\n$confrm_parameters\n$start_calculation\n";
close $fh;

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence &#x2713 <br> \n";
print HTML "Parsin BLAST output &#x2713 <br> \n";
print HTML "Performing MSA for first protein sequence &#x2713 <br> \n";
print HTML "Performing MSA for second protein sequence &#x2713 <br> \n";
print HTML "Running i2h&MT pipeline &#x2713 <br> \n";
print HTML "Running Genomics pipeline.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

system ("sh Start.sh < GNMX_PIPELINE_PARAMETERS");

chdir;

##COLLECT_GENOMICS_RESULTS

system("cat $header > $progress_url");
open(HTML,">>$progress_url");
print HTML "MetaPred2cs Starting &#x2713 <br> \n";
print HTML "Reading Parameters &#x2713 <br> \n";
print HTML "Starting BLAST &#x2713 <br> \n";
print HTML "BLASTing first protein sequence &#x2713 <br> \n";
print HTML "BLASTing second protein sequence &#x2713 <br> \n";
print HTML "Parsin BLAST output &#x2713 <br> \n";
print HTML "Performing MSA for first protein sequence &#x2713 <br> \n";
print HTML "Performing MSA for second protein sequence &#x2713 <br> \n";
print HTML "Running i2h&MT pipeline &#x2713 <br> \n";
print HTML "Running Genomics pipeline &#x2713 <br> \n";
print HTML "Running Support Vector Machine.. <br> \n";
close(HTML);
system("cat $footer >> $progress_url");

#print "Collecting results from individual predictors\n";

chdir "$GFM_OUTPUT";

system ("mv resultFile.bioverse GFM_Results.$ARGV[15] && cp GFM_Results.$ARGV[15] $Results_Genomics");

chdir "$PPM_OUTPUT";

system ("mv resultFileWithScore.bioverse PPM_Results.$ARGV[15] && cp PPM_Results.$ARGV[15] $Results_Genomics");

chdir "$GNM_OUTPUT";

system ("mv resultFile.bioverse GNM_Results.$ARGV[15] && cp GNM_Results.$ARGV[15] $Results_Genomics");

chdir "$GOM_OUTPUT";

system ("mv resultFile.bioverse GOM_Results.$ARGV[15] && cp GOM_Results.$ARGV[15] $Results_Genomics");

chdir "$GI2ID_index";

system ("cp seedGi2Id.properties seedGi2Id.$ARGV[15] && mv seedGi2Id.$ARGV[15] $Results_Genomics");

chdir;

#####################PARSING_GNMX_OUTPUTS##################################
###sonuclari virgul yerine tab ile ayir

chdir "$Results_Genomics";

my $cmd_result_parser = qx(perl -p -i -e 's/,/\t/g' GFM_Results.$ARGV[15] && perl -p -i -e 's/,/\t/g' PPM_Results.$ARGV[15] && perl -p -i -e 's/,/\t/g' GNM_Results.$ARGV[15] && perl -p -i -e 's/,/\t/g' GOM_Results.$ARGV[15]);


############CONVERT_INDEX_NUMBERS_TO_GIs#################################

my $cmd_GFM = qx(perl ayk1.pl GFM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 1clmn_gi.$ARGV[15] && perl ayk3.pl GFM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 2clmn_gi.$ARGV[15] && perl ayk5.pl 1clmn_gi.$ARGV[15] > 1clmn_ids.$ARGV[15] && perl ayk5.pl 2clmn_gi.$ARGV[15] > 2clmn_ids.$ARGV[15] && paste -d "-" 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] > result_ids_duz.$ARGV[15] && paste -d "-" 2clmn_ids.$ARGV[15] 1clmn_ids.$ARGV[15] > result_ids_ters.$ARGV[15] && rm -rf 1clmn_gi.$ARGV[15] 2clmn_gi.$ARGV[15] 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] && perl ayk7.pl GFM_Results.$ARGV[15] > scores.$ARGV[15] && paste -d "\t" result_ids_duz.$ARGV[15] scores.$ARGV[15] > GFM_Results_duz.$ARGV[15] && paste -d "\t" result_ids_ters.$ARGV[15] scores.$ARGV[15] > GFM_Results_ters.$ARGV[15] && sort -u GFM_Results_ters.$ARGV[15] -o GFM_Results_ters_sorted.$ARGV[15] && sort -u GFM_Results_duz.$ARGV[15] -o GFM_Results_duz_sorted.$ARGV[15] && rm -rf result_ids_duz.$ARGV[15] result_ids_ters.$ARGV[15] GFM_Results_ters.$ARGV[15] GFM_Results_duz.$ARGV[15] scores.$ARGV[15] );

my $cmd_PPM = qx(perl ayk1.pl PPM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 1clmn_gi.$ARGV[15] && perl ayk3.pl PPM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 2clmn_gi.$ARGV[15] && perl ayk5.pl 1clmn_gi.$ARGV[15] > 1clmn_ids.$ARGV[15] && perl ayk5.pl 2clmn_gi.$ARGV[15] > 2clmn_ids.$ARGV[15] && paste -d "-" 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] > result_ids_duz.$ARGV[15] && paste -d "-" 2clmn_ids.$ARGV[15] 1clmn_ids.$ARGV[15] > result_ids_ters.$ARGV[15] && rm -rf 1clmn_gi.$ARGV[15] 2clmn_gi.$ARGV[15] 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] && perl ayk7.pl PPM_Results.$ARGV[15] > scores.$ARGV[15] && paste -d "\t" result_ids_duz.$ARGV[15] scores.$ARGV[15] > PPM_Results_duz.$ARGV[15] && paste -d "\t" result_ids_ters.$ARGV[15] scores.$ARGV[15] > PPM_Results_ters.$ARGV[15] && sort -u PPM_Results_ters.$ARGV[15] -o PPM_Results_ters_sorted.$ARGV[15] && sort -u PPM_Results_duz.$ARGV[15] -o PPM_Results_duz_sorted.$ARGV[15] && rm -rf result_ids_duz.$ARGV[15] result_ids_ters.$ARGV[15] PPM_Results_ters.$ARGV[15] PPM_Results_duz.$ARGV[15] scores.$ARGV[15]);

my $cmd_GNM = qx(perl ayk1.pl GNM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 1clmn_gi.$ARGV[15] && perl ayk3.pl GNM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 2clmn_gi.$ARGV[15] && perl ayk5.pl 1clmn_gi.$ARGV[15] > 1clmn_ids.$ARGV[15] && perl ayk5.pl 2clmn_gi.$ARGV[15] > 2clmn_ids.$ARGV[15] && paste -d "-" 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] > result_ids_duz.$ARGV[15] && paste -d "-" 2clmn_ids.$ARGV[15] 1clmn_ids.$ARGV[15] > result_ids_ters.$ARGV[15] && rm -rf 1clmn_gi.$ARGV[15] 2clmn_gi.$ARGV[15] 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] && perl ayk7.pl GNM_Results.$ARGV[15] > scores.$ARGV[15] && paste -d "\t" result_ids_duz.$ARGV[15] scores.$ARGV[15] > GNM_Results_duz.$ARGV[15] && paste -d "\t" result_ids_ters.$ARGV[15] scores.$ARGV[15] > GNM_Results_ters.$ARGV[15] && sort -u GNM_Results_ters.$ARGV[15] -o GNM_Results_ters_sorted.$ARGV[15] && sort -u GNM_Results_duz.$ARGV[15] -o GNM_Results_duz_sorted.$ARGV[15] && rm -rf result_ids_duz.$ARGV[15] result_ids_ters.$ARGV[15] GNM_Results_ters.$ARGV[15] GNM_Results_duz.$ARGV[15] scores.$ARGV[15]);

my $cmd_GOM = qx(perl ayk1.pl GOM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 1clmn_gi.$ARGV[15] && perl ayk3.pl GOM_Results.$ARGV[15] seedGi2Id.$ARGV[15] > 2clmn_gi.$ARGV[15] && perl ayk5.pl 1clmn_gi.$ARGV[15] > 1clmn_ids.$ARGV[15] && perl ayk5.pl 2clmn_gi.$ARGV[15] > 2clmn_ids.$ARGV[15] && paste -d "-" 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] > result_ids_duz.$ARGV[15] && paste -d "-" 2clmn_ids.$ARGV[15] 1clmn_ids.$ARGV[15] > result_ids_ters.$ARGV[15] && rm -rf 1clmn_gi.$ARGV[15] 2clmn_gi.$ARGV[15] 1clmn_ids.$ARGV[15] 2clmn_ids.$ARGV[15] && perl ayk7.pl GOM_Results.$ARGV[15] > scores.$ARGV[15] && paste -d "\t" result_ids_duz.$ARGV[15] scores.$ARGV[15] > GOM_Results_duz.$ARGV[15] && paste -d "\t" result_ids_ters.$ARGV[15] scores.$ARGV[15] > GOM_Results_ters.$ARGV[15] && sort -u GOM_Results_ters.$ARGV[15] -o GOM_Results_ters_sorted.$ARGV[15] && sort -u GOM_Results_duz.$ARGV[15] -o GOM_Results_duz_sorted.$ARGV[15] && rm -rf result_ids_duz.$ARGV[15] result_ids_ters.$ARGV[15] GOM_Results_ters.$ARGV[15] GOM_Results_duz.$ARGV[15] scores.$ARGV[15]);

#######################SCAN#######################################

my $cmd_GFM1 = qx(perl scn1_GFM.pl index.$ARGV[15] GFM_Results_duz_sorted.$ARGV[15] > GFM_duz_ortusenler.$ARGV[15] && perl scn3_GFM.pl index.$ARGV[15] GFM_Results_ters_sorted.$ARGV[15] > GFM_ters_ortusenler.$ARGV[15] && cat GFM_duz_ortusenler.$ARGV[15] GFM_ters_ortusenler.$ARGV[15] > GFM_ortusenler_total.$ARGV[15] && perl scn5.pl GFM_ortusenler_total.$ARGV[15] > GFM_ort_index.$ARGV[15] && grep -vf GFM_ort_index.$ARGV[15] index.$ARGV[15] > GFM_sifir_index.$ARGV[15]);
my $cmd_GFM2 = qx(perl sfr6.pl GFM_sifir_index.$ARGV[15] > GFM_varolmayanlar.$ARGV[15] && cat GFM_ortusenler_total.$ARGV[15] GFM_varolmayanlar.$ARGV[15] > GFM_ortusen_final.$ARGV[15] && rm -rf GFM_sifir_index.$ARGV[15] GFM_varolmayanlar.$ARGV[15] GFM_ortusenler_total.$ARGV[15] GFM_duz_ortusenler.$ARGV[15] GFM_ters_ortusenler.$ARGV[15] GFM_ort_index.$ARGV[15]);
#system ($cmd_GFM1);
#system ($cmd_GFM2);

my $cmd_PPM1 = qx(perl scn1_PPM.pl index.$ARGV[15] PPM_Results_duz_sorted.$ARGV[15] > PPM_duz_ortusenler.$ARGV[15] && perl scn3_PPM.pl index.$ARGV[15] PPM_Results_ters_sorted.$ARGV[15] > PPM_ters_ortusenler.$ARGV[15] && cat PPM_duz_ortusenler.$ARGV[15] PPM_ters_ortusenler.$ARGV[15] > PPM_ortusenler_total.$ARGV[15] && perl scn5.pl PPM_ortusenler_total.$ARGV[15] > PPM_ort_index.$ARGV[15] && grep -vf PPM_ort_index.$ARGV[15] index.$ARGV[15] > PPM_sifir_index.$ARGV[15]);
my $cmd_PPM2 = qx(perl sfr6.pl PPM_sifir_index.$ARGV[15] > PPM_varolmayanlar.$ARGV[15] && cat PPM_ortusenler_total.$ARGV[15] PPM_varolmayanlar.$ARGV[15] > PPM_ortusen_final.$ARGV[15] && rm -rf PPM_sifir_index.$ARGV[15] PPM_varolmayanlar.$ARGV[15] PPM_ortusenler_total.$ARGV[15] PPM_duz_ortusenler.$ARGV[15] PPM_ters_ortusenler.$ARGV[15] PPM_ort_index.$ARGV[15]);
#system ($cmd_PPM1);
#system ($cmd_PPM2);

my $cmd_GNM1 = qx(perl scn1_GNM.pl index.$ARGV[15] GNM_Results_duz_sorted.$ARGV[15] > GNM_duz_ortusenler.$ARGV[15] && perl scn3_GNM.pl index.$ARGV[15] GNM_Results_ters_sorted.$ARGV[15] > GNM_ters_ortusenler.$ARGV[15] && cat GNM_duz_ortusenler.$ARGV[15] GNM_ters_ortusenler.$ARGV[15] > GNM_ortusenler_total.$ARGV[15] && perl scn5.pl GNM_ortusenler_total.$ARGV[15] > GNM_ort_index.$ARGV[15] && grep -vf GNM_ort_index.$ARGV[15] index.$ARGV[15] > GNM_sifir_index.$ARGV[15]);
my $cmd_GNM2 = qx(perl sfr6.pl GNM_sifir_index.$ARGV[15] > GNM_varolmayanlar.$ARGV[15] && cat GNM_ortusenler_total.$ARGV[15] GNM_varolmayanlar.$ARGV[15] > GNM_ortusen_final.$ARGV[15] && rm -rf GNM_sifir_index.$ARGV[15] GNM_varolmayanlar.$ARGV[15] GNM_ortusenler_total.$ARGV[15] GNM_duz_ortusenler.$ARGV[15] GNM_ters_ortusenler.$ARGV[15] GNM_ort_index.$ARGV[15]);
#system ($cmd_GNM1);
#system ($cmd_GNM2);

my $cmd_GOM1 = qx(perl scn1_GOM.pl index.$ARGV[15] GOM_Results_duz_sorted.$ARGV[15] > GOM_duz_ortusenler.$ARGV[15] && perl scn3_GOM.pl index.$ARGV[15] GOM_Results_ters_sorted.$ARGV[15] > GOM_ters_ortusenler.$ARGV[15] && cat GOM_duz_ortusenler.$ARGV[15] GOM_ters_ortusenler.$ARGV[15] > GOM_ortusenler_total.$ARGV[15] && perl scn5.pl GOM_ortusenler_total.$ARGV[15] > GOM_ort_index.$ARGV[15] && grep -vf GOM_ort_index.$ARGV[15] index.$ARGV[15] > GOM_sifir_index.$ARGV[15]);
my $cmd_GOM2 = qx(perl sfr6.pl GOM_sifir_index.$ARGV[15] > GOM_varolmayanlar.$ARGV[15] && cat GOM_ortusenler_total.$ARGV[15] GOM_varolmayanlar.$ARGV[15] > GOM_ortusen_final.$ARGV[15] && rm -rf GOM_sifir_index.$ARGV[15] GOM_varolmayanlar.$ARGV[15] GOM_ortusenler_total.$ARGV[15] GOM_duz_ortusenler.$ARGV[15] GOM_ters_ortusenler.$ARGV[15] GOM_ort_index.$ARGV[15]);
#system ($cmd_GOM1);
#system ($cmd_GOM2);

my $cmd_clean_directory = qx(rm -rf GFM_Results.$ARGV[15] GFM_Results_duz_sorted.$ARGV[15] GFM_Results_ters_sorted.$ARGV[15] GNM_Results.$ARGV[15] GNM_Results_duz_sorted.$ARGV[15] GNM_Results_ters_sorted.$ARGV[15] GOM_Results.$ARGV[15] GOM_Results_duz_sorted.$ARGV[15] GOM_Results_ters_sorted.$ARGV[15] PPM_Results.$ARGV[15] PPM_Results_duz_sorted.$ARGV[15] PPM_Results_ters_sorted.$ARGV[15]);
#system ($cmd_clean_directory);

###########################PREPERATION_OF_FEATURE_VECTOR_FOR_SVM_PREDICTION################################

##MERGE_OUTPUTS_OF_INDIVIDUAL_PREDICTION_METHODS_FOR_INPUT_PAIR

my $cmd_merge_results = qx(join -t "`echo '\t'`" i2h_MT_results.$ARGV[15].final_sorted GFM_ortusen_final.$ARGV[15] > joint1.$ARGV[15] && join -t "`echo '\t'`" joint1.$ARGV[15] PPM_ortusen_final.$ARGV[15] > joint2.$ARGV[15] && join -t "`echo '\t'`" joint2.$ARGV[15] GNM_ortusen_final.$ARGV[15] > joint3.$ARGV[15] && join -t "`echo '\t'`" joint3.$ARGV[15] GOM_ortusen_final.$ARGV[15] > merged_outputs.$ARGV[15] && rm -rf joint1.$ARGV[15] joint2.$ARGV[15] joint3.$ARGV[15] i2h_MT_results.$ARGV[15].final_sorted GFM_ortusen_final.$ARGV[15] PPM_ortusen_final.$ARGV[15] GNM_ortusen_final.$ARGV[15] GOM_ortusen_final.$ARGV[15] && perl prepare_svm_input.pl merged_outputs.$ARGV[15] > merged_outputs_svm_format.$ARGV[15] && rm -rf merged_outputs.$ARGV[15] && mv merged_outputs_svm_format.$ARGV[15] /var/www/webserver_okul/programs/libsvm-3.17);

chdir;

###Scale//Submit//Parse_Result###

chdir "$SVM_workdir";

my $cmd_scale_predict = qx(cat merged_outputs_svm_format.$ARGV[15] SVM_input_file_range > input_in_reference_range_file.$ARGV[15] && ./svm-scale -l -1 -u 1 -s range.$ARGV[15] input_in_reference_range_file.$ARGV[15] > input_in_reference_range_file.$ARGV[15].scaled && head -1 input_in_reference_range_file.$ARGV[15].scaled > merged_outputs_svm_format.$ARGV[15].scaled && ./svm-predict merged_outputs_svm_format.$ARGV[15].scaled Main_classifier_cv10.model out.$ARGV[15] > decision_values.$ARGV[15].1 && head -1 decision_values.$ARGV[15].1 > decision_values.$ARGV[15] && perl Re-format_decision.pl decision_values.$ARGV[15] > decision_values_formatted.$ARGV[15] && cat decision_values_formatted.$ARGV[15] SVM_Decision_Values_app_range > decision_value_in_range_file.$ARGV[15] && ./svm-scale -l 0 -u 1 -s range.$ARGV[15] decision_value_in_range_file.$ARGV[15] > decision_value_in_range_file_scaled.$ARGV[15] && head -1 decision_value_in_range_file_scaled.$ARGV[15] > decision_value_scaled.$ARGV[15] && rm -rf  decision_values.$ARGV[15].1 decision_values_formatted.$ARGV[15] decision_values.$ARGV[15] decision_value_in_range_file.$ARGV[15] range.$ARGV[15] decision_value_in_range_file_scaled.$ARGV[15]);


#system ($cmd_scale_predict);

my $file4 = "decision_value_scaled.$ARGV[15]";
my $decision_value_parser = qx(perl -p -i -e 's/0 1://g' $file4);

my $cmd_scale_predict2 = qx(paste -d "\t" out.$ARGV[15] decision_value_scaled.$ARGV[15] > SVM_Result.$ARGV[15] && paste -d "\t" merged_outputs_svm_format.$ARGV[15] SVM_Result.$ARGV[15] > Meta-Predictor_Final_Result.$ARGV[15] && rm -rf out.$ARGV[15] decision_value_scaled.$ARGV[15] && mv Meta-Predictor_Final_Result.$ARGV[15] /var/www/webserver_okul/RESULTS/SVM);

#system ($cmd_scale_predict2);

chdir;

#####Print_final_output#######

chdir "$SVM_OUTPUT";

system ("chmod 755 Meta-Predictor_Final_Result.$ARGV[15] && perl read_print.pl Meta-Predictor_Final_Result.$ARGV[15] $ARGV[15] $ARGV[0] $ARGV[1] $fl3 $fl4 $ARGV[13] $ARGV[14] $ARGV[2] $ARGV[3] $ARGV[4] $ARGV[5] $ARGV[6] $ARGV[7] $ARGV[8] $ARGV[9] $ARGV[10] $ARGV[11] $ARGV[12]"); 
#&& perl read_print.pl Meta-Predictor_Final_Result.$ARGV[15] $progress_url $header $footer ");

chdir;

##########CLEAN_DIRECTORIES############
##i2h_package

chdir "$i2h_workdir";

system ("rm -rf i2h_MT_results.$ARGV[15] $prt1 $prt2");

chdir;

##GNMX_PIPELINE
#chdir "$GNMCS_PIPELINE_workdir_clean"; 

#system ("rm -rf workDir.$ARGV[15]");

#chdir;
 
chdir "$Results_Genomics";

system ("rm -rf index.$ARGV[15] seedGi2Id.$ARGV[15]"); 

chdir;

##SVM
chdir "$SVM_workdir";

system ("rm -rf input_in_reference_range_file.$ARGV[15] input_in_reference_range_file.$ARGV[15].scaled merged_outputs_svm_format.$ARGV[15] merged_outputs_svm_format.$ARGV[15].scaled SVM_Result.$ARGV[15]");

chdir;

##
exit;
