/**
 * Calling JointEntropyTreat function from java.
 * 
 * Filename: org_biosino_util_jni_JETreat.c 
 * Version: 0.001
 * Author: Guohui Ding
 * Copyright 2005 BIOSINO, SIBS, CAS. All rights reserved.
 */
#include "org_biosino_util_jni_JETreat.h"
#include "JointEntropyTreat.h"
#include <string.h>
#include <stdlib.h>

JNIEXPORT void JNICALL Java_org_biosino_util_jni_JETreat_doJointEntropyTreat
  (JNIEnv * env, jclass cl, jdouble cutoff, jint gNum, jstring pro, jstring tax, 
   jstring eVal, jstring outDir, jstring outFile) {
     const char* proteinIDFile; 
	 const char* taxonIDFile; 
     const char* eValueFile; 
	 const char* outdir;
	 const char* outfile;

	proteinIDFile = env->GetStringUTFChars(pro, NULL);
	taxonIDFile = env->GetStringUTFChars(tax, NULL);
	eValueFile = env->GetStringUTFChars(eVal, NULL);
	outdir = env->GetStringUTFChars(outDir, NULL);
	outfile = env->GetStringUTFChars(outFile, NULL);

	/*
	 * Call function JointEntropyTreat.
	 */
	JointEntropyTreat(cutoff, gNum, (char*)proteinIDFile, (char*)taxonIDFile, (char*)eValueFile, (char*)outdir, (char*)outfile);
  }
