/* 
 * File name  : InPrePPIDemo.java
 * Authors    : Guohui Ding
 * Created    : Sun 06 Nov 2005 09:44:56 PM CST
 * Copyright  : Copyright 2005 BIOSINO, SIBS, CAS. All rights reserved.
 *
 * Modifications:
 *
 */
import org.biosino.util.*;
import org.biosino.util.ppi.*;

import java.io.*;
import java.util.*;
import java.util.logging.*;

class InPrePPIDemo {
	private static BufferedReader in = null;
	private static Logger log = Logger.getLogger("org.biosino.InPrePPI");
	
	public static void main(String[] args) throws Exception{ 
		log.setLevel(Level.ALL);
		log.setUseParentHandlers(false);
		Handler handler = new ConsoleHandler();
//		FileHandler fhl = new FileHandler();
//		fhl.setLevel(Level.ALL);
		handler.setLevel(Level.FINE);
		log.addHandler(handler);
//		log.addHandler(fhl);
		
		 in = new BufferedReader(new InputStreamReader(System.in));
		 System.out.println(" *********************************************");
		 System.out.println("You can set the parameters as yourself, or \n"
				 + " just use the default value by typing the enter key!");
		 System.out.println();
		 System.out.println(" *********************************************");
		 
		 // set the base system's directory
		 String baseSys = getInputString("Set the directory containing the basic "
				 + "system files, \n the default direcotry is \"../sys\"");
		if (baseSys.equals(""))
			 baseSys = "../sys";
		 File baseSysDir = new File(baseSys);
		 if (!baseSysDir.exists()) {
			 System.err.println("WARNING: The base system directory doesnot " 
					 + "exist!!");
			 System.exit(1);
		 }
		 
		// set the computer system's parameters
		 String cpuNum = getInputString("Set the number of the cpu used in all"
				 + " to all BLASTP and RPSBLAST,\n the default value is 1!");
		 if (cpuNum.equals(""))
			 cpuNum = "1";

		 String taxId = getInputString("If the seed taxon is in the OUR's"
				 + " dabase, you can type the integer id of the taxon!\n"
				 + " Also you can set all the files yourself, just type" 
				 + " the enter key!");
		 System.out.println(" *********************************************");
		 
		 // set the seed's files and distance file
		 System.out.println(" *********************************************");
		 String seed = null;
		 String ptt = null;
		 String tus = null;
		 String dist = null;
		 String seedTaxonId = "seed";

		 String isPttUserDefineStr = "";
		 boolean isPttUserDefine = false;
		 
		 if (taxId.equals("")) {
			 seed = getInputString("Input name of the seed's fasta file, the " 
				+ "default file is \"seed.faa\" in working directory!");
			 ptt = getInputString("Input the name of the directory that "
				+ "contain the seed's ptt files, the default directory is "
				+ "\"seedPtt\" in working directory!");
			 isPttUserDefineStr = getInputString("Is this ptt file's format "
					 + "defined by the user?\n"
					 + " Type \"yes\" or \"no\", and the "
					 + "default value is \"no\" !\n"
					 + "yes-->user define; no-->NCBI standard format");
			 tus = getInputString("Input the name of the seed's tus file,"
				+ " the default value is \"seed.tus\" in the working "
				+ "directory!");
			 dist = getInputString("Input the name of the 16S RNA Evolutonary "
				+ " distance file,"
				+ " the default value is \"mix/dist.mat\" in the basic system "
				+ "directory!");
			 seedTaxonId = getInputString("Input the name of the seed taxon "
				+ " which is used in the 16S RNA Evolutionary distance file!\n"
				+ " The default value is \"seed\"");
		 } else {
			 seed = baseSysDir.getAbsolutePath() + "/data/Formatedpttfaa/faa/" 
				 + taxId + "Src";
			 ptt = baseSysDir.getAbsolutePath() + "/data/Formatedpttfaa/ptt/"
				 + taxId;
			 tus = baseSysDir.getAbsolutePath() + "/data/Formatedoperon/operon/"
				 + taxId;
			 dist = baseSysDir.getAbsolutePath() + "/mix/dist.mat";
			 seedTaxonId = taxId;
		 }
		 if (isPttUserDefineStr.toUpperCase().startsWith("Y"))
			 isPttUserDefine = true;
		 if (seed.equals(""))
			 seed = "seed.faa";
		 if (ptt.equals(""))
			 ptt = "seedPtt";
		 if (tus.equals(""))
			 tus = "seed.tus";
		 if (dist.equals(""))
			 dist = baseSysDir.getAbsolutePath() + "/mix/dist.mat";
		 if (seedTaxonId.equals(""))
			 seedTaxonId = "seed";
		 	
		 File seedFile = new File(seed);
		 File pttFile = new File(ptt);
		 File tusFile = new File(tus);
		 File distFile = new File(dist);
		 boolean pttF = true;
		 boolean tusF = true;
		 
		 if (!seedFile.exists()) {
			 System.err.println("WARNING: The seed genomes sequences don't exists!");
			 System.exit(1);
		 }
		 if (!pttFile.exists()) {
			 System.err.println("WARNING: The ptt file don't exists!");
			 System.err.println("WARNING: The gene neighbor method can't be "
					 + " used!");
			 pttF = false;
		 }
		 if (!tusFile.exists()) {
			 System.err.println("WARNING: The tus file don't exists!");
			 System.err.println("WARNING: The gene operon method can't be "
					 + " used!");
			 tusF = false;
		 }
		 if (!distFile.exists()) {
			 System.err.println("WARNING: The 16S RNA Evolutionary distance "
					 + " File doesn't exists!");
		 }
		 System.out.println(" *********************************************");

		 //Chose the method used in a user project
		 boolean uni = true;
		 boolean ppm = true;
		 boolean gfm = true;
		 boolean gnm = true;
		 boolean gom = true;
		 boolean us = true;
		 
		 System.out.println(" *********************************************");
		 System.out.println("Do you want to use all method and get a unioned "
				 + " score?");
		 String uniStr = getInputString(" Type \"yes\" or \"no\", and the "
				 + "default value is \"yes\" !");
		 if (uniStr.equals(""))
			 uniStr = "yes";
		 if (uniStr.toUpperCase().startsWith("Y"))
			 uni = true;
		 else
			 uni = false;
		 
		 if (!uni) {
			 System.out.println("Do you want to use Phylogeny Profile Method?");
			 String ppmStr = getInputString(" Type \"yes\" or \"no\", and the "
				 + "default value is \"yes\" !");
			 if (!(ppmStr.equals("") || ppmStr.toUpperCase().startsWith("Y")))
				 ppm = false;
			 
			 System.out.println("Do you want to use gene fusion Method?");
			 String gfmStr = getInputString(" Type \"yes\" or \"no\", and the "
				 + "default value is \"yes\" !");
			 if (!(gfmStr.equals("") || gfmStr.toUpperCase().startsWith("Y")))
				 gfm = false;
			 
			 System.out.println("Do you want to use gene neighbor Method?");
			 String gnmStr = getInputString(" Type \"yes\" or \"no\", and the "
				 + "default value is \"yes\" !");
			 if (!(gnmStr.equals("") || gnmStr.toUpperCase().startsWith("Y")))
				 gnm = false;
			 
			 System.out.println("Do you want to use gene operon Method?");
			 String gomStr = getInputString(" Type \"yes\" or \"no\", and the "
				 + "default value is \"yes\" !");
			 if (!(gomStr.equals("") || gomStr.toUpperCase().startsWith("Y")))
				 gom = false;

			 System.out.println("Do you want to union the Result?");
			 String usStr = getInputString(" Type \"yes\" or \"no\", and the "
				 + "default value is \"yes\" !");
			 if (!(usStr.equals("") || usStr.toUpperCase().startsWith("Y")))
				 us = false;

		 }
		 
		 //set the parameters for each method
	 	 //Phylogeny Profile method
		 System.out.println(" *********************************************");
		 double ppmJointEntropyCutoff = 0.35;
		 double ppmEvaluelCutoff = 1e-4;
		 File ppmSelectedTaxonFile = new File("SelectedTaxon.properties"); 

		 if (uni || ppm) {
		 	System.out.println("SET THE PARAMETERS FOR Phylogeny Profile" 
				+ "method!");
		 	String pjec = getInputString("Set the cutoff value of the "
				+ " joint entrophy calculation! (Default value is 0.35)");
			String pec = getInputString("Set the cutoff value of the "
				+ " NCBI BLASTP's E value for protein mapping to taxon! "
				+ "(Default value is 1e-4)");
			String pst = getInputString("Set the file containing the selected "
				+ "reference taxon, the default file is "
				+ "\"SelectedTaxon.properties\"");

			if (!pjec.equals(""))
				ppmJointEntropyCutoff = Double.parseDouble(pjec);
			if (!pec.equals(""))
				ppmEvaluelCutoff = Double.parseDouble(pec);
			if (!pst.equals(""))
				ppmSelectedTaxonFile = new File(pst);
		 }
		 		 
		 System.out.println(" *********************************************");
		 
		 //Gene fusion method 
		 System.out.println(" *********************************************");
		 double gfmEvalueCutoff = 1e-5;
		 double gfmCutoffForBits = 30;
		 File gfmSelectedTaxonFile = new File("SelectedTaxon.properties");
		 if (uni || gfm) {
		 	 System.out.println("SET THE PARAMETERS FOR Gene Fusion Method!"); 
			 String gfec = getInputString("Set the cutoff value of the "
					 + "all to all NCBI BLASTP's E value!\n"
					 + "The default value is 1e-5!");
			 String gfbc = getInputString("Set the cutoff value of the "
					 + " Bits in the ssearch34!\n"
					 + "The default value is 30!");
			 String gfst = getInputString("Set the file containing the selected "
				+ "reference taxon, the default file is "
				+ "\"SelectedTaxon.properties\"");

			 if (!gfec.equals(""))
				 gfmEvalueCutoff = Double.parseDouble(gfec);
			 if (!gfbc.equals(""))
				 gfmCutoffForBits = Double.parseDouble(gfbc);
			 if (!gfst.equals(""))
				 gfmSelectedTaxonFile = new File(gfst);
		 }
		 System.out.println(" *********************************************");

		 //Gene neighbor method
		 System.out.println(" *********************************************");
		 	//The nucleic acids distance to define the neighbor genes
		 int gnmDist = 300; 
		 double gnmEvalueCutoff = 1e-5;
		 File gnmSelectedTaxonFile = new File("SelectedTaxon.properties");
		 if (pttF && (uni || gnm)) {
		 	 System.out.println("SET THE PARAMETERS FOR Gene Neighbor Method!"); 
			 String gndt = getInputString("Set the nucleic acids distance "
					 + " used to define the neighbor genes.\n"
					 + "The default value is 300!");
			 String gnec = getInputString("Set the cutoff value of the "
					 + "all to all NCBI BLASTP's E value!\n"
					 + "The default value is 1e-5!");
			 String gnst = getInputString("Set the file containing the "
					  + "selected reference taxon, the default file is "
					  + "\"SelectedTaxon.properties\"");
			 
			 if (!gndt.equals("")) 
				 gnmDist = Integer.parseInt(gndt);
			 if (!gnec.equals(""))
				 gnmEvalueCutoff = Double.parseDouble(gnec);
			 if (!gnst.equals(""))
				 gnmSelectedTaxonFile = new File(gnst);
		 }
		 System.out.println(" *********************************************");
		 
		 //Gene operon method
		 System.out.println(" *********************************************");
		 double gomEvalueCutoff = 1e-5;
		 File gomSelectedTaxonFile = new File("SelectedTaxon.properties");
		 if (tusF && (uni || gom)) {
		 	 System.out.println("SET THE PARAMETERS FOR Gene Operon Method!"); 
			 String goec = getInputString("Set the cutoff value of the "
					 + "all to all NCBI BLASTP's E value!\n"
					 + "The default value is 1e-5!");
			 String gost = getInputString("Set the file containing the "
					  + "selected reference taxon, the default file is "
					  + "\"SelectedTaxon.properties\"");
			 
			 if (!goec.equals(""))
				 gomEvalueCutoff = Double.parseDouble(goec);
			 if (!gost.equals(""))
				 gomSelectedTaxonFile = new File(gost);
		 }
		 System.out.println(" *********************************************");

		 boolean blast = true;
//		 boolean mapCOG = true;
		 String blastStr = getInputString("Do you want to omit the "
				 + "all to all BLASTP if you did it before?\n"
				 + "Type \"yes\" or \"no\", the default value is \"no\"");
//		 String mapCOGStr = getInputString("Do you want to omit the "
//				 + "the RPSBLAST for mapping the sequences to COG?\n"
//				 + "Type \"yes\" or \"no\", the default value is \"no\"");
				 
		 if (blastStr.toUpperCase().startsWith("Y"))
			 blast = false;
//		 if (mapCOGStr.toUpperCase().startsWith("Y"))
//			 mapCOG = false;
		 
		 String confirmStr = getInputString("Are you sure of all the setting?\n"
				 + " Type \"yes\" or \"no\", the default value is \"yes\"");
		 String confirmAgainStr = getInputString("Confirm Again!\n" 
				 + " Type \"yes\" or \"no\", the default value is \"yes\"");
		 boolean confirm = true;
		 boolean confirmA = true;
		 if (confirmStr.toUpperCase().startsWith("Y") ||
				 confirmStr.equals(""))
			 confirm = true;
		 else
			 confirm = false;
		 if (confirmAgainStr.toUpperCase().startsWith("Y") ||
				 confirmAgainStr.equals(""))
			 confirmA = true;
		 else 
			 confirmA = false;
			
		 if (!(confirm && confirmA))
			 System.exit(1);
		 in.close();
	 		 
//		 System.out.println("seed: " + seed);
//		 System.out.println("cpu number: " + cpuNum);
//		 System.out.println("basic system directory:" + baseSys);

		 //BEGIN THE CACULATION
		 System.out.println(" NOW START THE PPI PREDICTION .......");
		 //all to all blastp
		 if (blast) {
			 System.out.println(" ALL TO ALL BLASTP: START ");
			 BatchAlltoAllBlastp bp = new BatchAlltoAllBlastp(seedFile, 
					 new File(baseSysDir, "data/Formatedpttfaa"));
			 bp.formatSeedSeq();
			 bp.alltoAllBlastp(Integer.parseInt(cpuNum), 8);
			 System.out.println(" ALL TO ALL BLASTP: END ");
		 } else
			 System.out.println("The all to all blastp was omitted!");
		 
		 //Map the seed sequence to COG function catalog
/*		 if (mapCOG) {
			 System.out.println(" RPSBLAST: START ");
			 GenomeSeqMapToCOGFunction gsf = new GenomeSeqMapToCOGFunction(
					 new File("AlltoAllBlastPTableOut/seedDir/seed"),
					 new File(baseSysDir, "data/COG/database/"), 
					 new File("AlltoAllBlastPTableOut/seedDir"),
					 new File(baseSysDir, "data/COG/cddid2fun.properties"));
			 gsf.mapToCOGFunction(Integer.parseInt(cpuNum), 1e-5);
			 System.out.println(" RPSBLAST: START ");
		 } else
			 System.out.println("The RPSBLAST was omitted!");
*/
		 
		 //PPI prediction with PPM
		 if (uni || ppm) {
			 System.out.println("PPM: START!");
			 PPM ppmPre = new PPM();
			 
			 if (ppmPre.prepare(ppmSelectedTaxonFile, ppmEvaluelCutoff))
				 ppmPre.doPrediction(ppmJointEntropyCutoff);
			 ppmPre.uniformResult();
			 System.out.println("PPM: END!");
			 System.gc();
		 }

		 //PPI prediction with GFM
		 if (uni || gfm) { 
			 System.out.println("GFM: START!");
			 GFM gfmPre = new GFM();

			 if (gfmPre.prepare(gfmSelectedTaxonFile))
				 gfmPre.doPrediction(gfmEvalueCutoff, gfmCutoffForBits,
						 distFile, seedTaxonId);
			 gfmPre.uniformResult();
			 System.out.println("GFM: END!");
			 System.gc();
		 }

		//PPI prediction with GNM
		if (pttF && (uni || gnm)) {
			System.out.println("GNM: START!");
			GNM gnmPre = new GNM(new File("AlltoAllBlastPTableOut"), 
					new File(baseSysDir, "data/Formatedpttfaa/"),
					pttFile, new File("Result"));

			if (gnmPre.prepare(gnmSelectedTaxonFile)) 
				gnmPre.doPrediction(isPttUserDefine, gnmDist, gnmEvalueCutoff,
						distFile, seedTaxonId);
			gnmPre.uniformResult();
			System.out.println("GNM: END!");
			System.gc();
		}

		//PPI prediction with GOM
		if (tusF && (uni || gom)) {
			System.out.println("GOM: START!");
			GOM gomPre = new GOM(new File("AlltoAllBlastPTableOut"), 
					new File(baseSysDir, "data/Formatedoperon/"),
					tusFile, new File("Result"));

			if (gomPre.prepare(gomSelectedTaxonFile))
				gomPre.doPrediction(gomEvalueCutoff, distFile, seedTaxonId);
			gomPre.uniformResult();
			System.out.println("GOM: END!");
			System.gc();
		}

		//Union Scoring
		if (us) {
			System.out.println("UNION: START!");
			UnionScoring usPre = new UnionScoring(new File("Result"),
					new File(baseSysDir, "mix/auc.mat"),
					new File("AlltoAllBlastPTableOut"),
					new File("Result"));

			if (usPre.prepare())
				usPre.doPrediction();
			usPre.uniformResult();
			System.out.println("UNION: END!");
			System.gc();
		}
	}

	private static String getInputString(String promt) throws IOException {
		System.out.println(promt);
		return in.readLine().trim();
	}
}
