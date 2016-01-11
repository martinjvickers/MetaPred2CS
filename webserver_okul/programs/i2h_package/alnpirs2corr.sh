#!/bin/sh

																			 

if test $# -lt 7
then
        echo '\n\n** Usage:  alnpirs2corr  seqfile1.alnpir   seqfile2.alnpir   min_matches  max_matches   (corr||rankorr)   matrix  results_file(append)\n\n'
        exit
fi


#
# "aln_two"
# Este programa es el que habria que modificar por el rollo de los
# paralogos/ortologos, etc.
#
./i2hbin/aln_two_euc2_nopar_max $1 $2 $3 $4


#
# Generate HSSP
# Here could be good to test alignment quality:!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# No too distant proteins in the HSSP, etc.
# This could be done inside "twoprotalnpir2hssp" or outside it.
#
# Run also CORR/RANKORR, MIRRORTREE & ID
#
# This is also the point to save results.
#

./i2hbin/twoprotalnpir2corr $1 $2 $6 $5 $7


#
# Deleting some stuff ...
#
