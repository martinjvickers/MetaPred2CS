/**
 * A C++ implementation of the joint entropy calculation. The original C program 
 * was written by Wei Huang in TsingHua University with MicroSoft C, which can be 
 * got from the me by Email(gwding@biosino.org). Wei Huang do the anotation with Chinese, 
 * and I maintain them.
 *
 * Filename: JointEntropyTreat.c
 * Version: 0.001
 * Author: Guohui Ding, Wei Huang, Ziliang Qian
 * Copyright 2005 BIOSINO, SIBS, CAS. All rights reserved.
 */
#include <sys/stat.h>
#include <sys/types.h>
//#include <stdio.h>
#include <fcntl.h>
#include <unistd.h> 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
//#include <direct.h>
#include <sys/dir.h>
#define MAX 13       //�����ֵ
//#define GeneNum 127  //���������
int GeneNum = 123;

#define LimitedNum 0.0001  //���������

#include <string>
#include <vector>

// Added by Ziliang Qian in BIOSINO
void itoa(int value, std::string& buf, int base)
{
int i = 30;
buf = "";
for(; value && i ; --i, value /= base) buf = "0123456789abcdef"[value % base] + buf;
}

typedef struct ProteinRecord	//һ�������ʼ�¼   �˽ṹ������������������ļ������Ľ������JointEntropy  SelfEntropy������������Ҫ�õ�
{
	int RecordNo;				//�����ʱ��         ����10383750
	std::vector<int> factor;		//��׼���Ժ�ĵ����ʶԻ�������ֵ ����12	
	struct ProteinRecord *next;   //ָ����һ���ڵ㣬��������ʱ����������һ���ڵ�

public:
	ProteinRecord():factor(std::vector<int>(GeneNum,0)){};
	ProteinRecord& operator = (ProteinRecord& ref)
	{
		this->RecordNo=ref.RecordNo;
		this->factor=ref.factor;
		this->next=ref.next;
	}
} ProteinRecord	;

typedef struct ProteinGeneRecord	//һ�������ʻ������¼
{
	int ProteinNo;				//�����ʱ��         ����10383750
	int GenomeNo;               //��������         ����20
	double e;		             //��Ӧ��eֵ         ���� 3.0e-035
    struct ProteinGeneRecord *next;   //ָ����һ���ڵ㣬��������ʱ����������һ���ڵ�
} ProteinGeneRecord	;

typedef struct ProteinId	//һ�������ʱ��
{
	int proteinid;				//�����ʱ��         ����10383750
	struct ProteinId   *next;	  //ָ����һ���ڵ㣬��������ʱ����������һ���ڵ�
} ProteinId	;

typedef struct GenomeId	       //һ����������
{
	int genomeid;				//��������         ����20
	struct GenomeId  *next;		
} GenomeId	;	

double JointEntropy(ProteinRecord *, ProteinRecord *);
double SelfEntropy(ProteinRecord *);

/**
 * A function applied to calculate the joint entropy of a pair of 
 * protein. The interface of this function is added by Guohui Ding.
 *
 * @param cutoff the cutoff value for the joint entropy.
 * @param genomeNum the taxon/genome number.
 * @param ProteinIDFile the name of the file that contains the 
 * protein ids.
 * @param taxonIDFile the name of the file which includes the 
 * taxon ids.
 * @param eValueFile the name of the file which includes the protein 
 * E values.
 * @param resultFile the name of the file storing the candidate pairs.
 * @param profileFile the file storing the profile of the protein.
 */

int JointEntropyTreat(double cutoff, int genomeNum, char* proteinIDFile, 
		char* taxonIDFile, char* eValueFile, char* resultFile,
		char * profileFile)
{
	GeneNum = genomeNum; //get the maximum number of genomes
	
	int i,h,j;
	std::string tmp;
	double entropy=0;
	double mi=0;
	double cf = 0;

	FILE *input,*output,*input1,*input2;
	FILE *output1;     //�������ProteinRecord�ṹ��

	char InputFileName[256]={'\0'}; //�����ļ���
	char InputFileName1[256]={'\0'};
	char InputFileName2[256]={'\0'};
	
	 char OutputDir[256]={'\0'};
	 char OutputFileNameSuffix[]=".txt"; //����ļ�����׺
	char OutputFileName[256]={'\0'};  //����������ļ���
	char OutputFileName1[256]={'\0'};  // �������ProteinRecord�ṹ��


	int genomenum=0;          //��¼����������
	int proteinnum=0;        // ��¼����������
	int count=0;             //��¼blastp.txt�ļ��ж�����
	double enu=0;
	int marker;             //�����ж�blastp.txt�ļ����Ƿ��е�ǰ�����ʱ�źͻ������ŵĶ�Ӧֵ
	double result=0;
	//�Ը��������ͷָ����г�ʼ��
	ProteinRecord *pr=new ProteinRecord;
	ProteinGeneRecord *pgr=new ProteinGeneRecord;
    ProteinId   *pi=new ProteinId;
    GenomeId	*gi=new GenomeId;
	//Ϊ�˱�������������ӵ���ʱ����
//////////////////////////////////////////////////////////////////////////////
	ProteinRecord *pr_temp,*pr_temp2;     //���׼�¼
	ProteinGeneRecord *pgr_temp,*pgr_temp2;
    ProteinId   *pi_temp,*pi_temp2;
    GenomeId	*gi_temp,*gi_temp2;

/////////////////////////////////////////////////////////////////////////////////////

	
//	strcpy(InputFileName,"gi.txt");
	strcpy(InputFileName,proteinIDFile);
//    strcpy(InputFileName1,"127g");
    strcpy(InputFileName1, taxonIDFile);
//    strcpy(InputFileName2,"e127");
    strcpy(InputFileName2, eValueFile);
//    strcpy(OutputDir,"127");
    strcpy(OutputDir, resultFile);
	
//    strcpy(OutputFileName1,"p127");
    strcpy(OutputFileName1, profileFile);
	
//	mkdir(OutputDir,0777);           //�����û������Ŀ¼����һĿ¼

	if((input=fopen(InputFileName,"r"))==NULL)
	{
     	printf( "�ļ�������� :-- %s\n", InputFileName);		 
     	return 1;
	}
	if((input1=fopen(InputFileName1,"r"))==NULL)
	{
     	printf( "�ļ�������� :-- %s\n", InputFileName1);		 
     	return 1;
	}
	if((input2=fopen(InputFileName2,"r"))==NULL)
	{
     	printf( "�ļ�������� :-- %s\n", InputFileName2);		 
     	return 1;
	}
	 
    //��gi.txt�е����ݶ��뵽piָ���������
     pi_temp=pi;//��ͷ�ڵ�ָ�븳��pi_temp
	while(1)                                      
	{	
		fscanf(input,"%d",&(pi_temp->proteinid));     //��ÿ�еĵ����ʱ�Ŵ浽 ProteinId �ṹ��
	    
	    if(feof(input)) {pi_temp->next=0; break;}
        proteinnum++;
		 pi_temp->next=new ProteinId;   //������һ���ڵ㣬���ǻ�û��ֵ,����һ��ѭ�����ļ��ж�ȡֵ
        pi_temp2=pi_temp;    //Ϊ���޳��ļ�������һ��ֵ����ֵ�Ǳ�ʶ�ļ���β�ģ�����Ӧ�޳������ӵ���ʱ����
		pi_temp=pi_temp->next; //��pi_tempָ����һ���ڵ�
       
	}
    pi_temp2->next=0;
	free(pi_temp);  //�޳��ļ�������һ��ֵ

    gi_temp=gi;
	while(1)                                   //��ÿ�еĻ������Ŵ浽 GenomeId �ṹ��
	{   
		fscanf(input1,"%d",&gi_temp->genomeid);
		
	    if(feof(input1)) {gi_temp->next=0;break;}
		genomenum++;
		gi_temp->next=new GenomeId;
		gi_temp2=gi_temp;
		gi_temp=gi_temp->next;
	}
    gi_temp2->next=0;
	free(gi_temp);


    pgr_temp=pgr;
	while(1)                                  //��blastp.txt�����ݴ���  ProteinGeneRecord �ṹ��
	{
		fscanf(input2,"%d",&pgr_temp->ProteinNo);
		fscanf(input2,"%d",&pgr_temp->GenomeNo);
		fscanf(input2,"%lf",&pgr_temp->e);
		if(feof(input2)) {pgr_temp->next=0; break;}
		count++;

		
        pgr_temp->next=new ProteinGeneRecord;
        pgr_temp2=pgr_temp;
		pgr_temp=pgr_temp->next;
    }
	pgr_temp2->next=0;
	free(pgr_temp);

		fclose(input);
	    fclose(input1);
	    fclose(input2);

    pr_temp=pr;//��ͷ�ڵ�ָ�븳��pr_temp
	pi_temp=pi;//��ͷ�ڵ�ָ�븳��pi_temp
	for(i=0;i<proteinnum;i++)
	{
	   pr_temp->RecordNo = pi_temp->proteinid;    // �ѵ����ʱ�Ÿ���ProteinRecord�ṹ��
	    
	  
		for(j=0,gi_temp=gi;j<genomenum;j++,gi_temp=gi_temp->next/*gi_tempָ����һ���ڵ㣬ʵ�����ݱ�������ͬ*/)
		{
               marker=0;
			for(pgr_temp=pgr,pgr_temp2=pgr;pgr_temp!=0;pgr_temp2=pgr_temp,pgr_temp=pgr_temp->next)  
			{
				if((pgr_temp->ProteinNo == pi_temp->proteinid) && (pgr_temp->GenomeNo == gi_temp->genomeid))    
				{
					if(pgr_temp->e <= LimitedNum)  
					{
						enu=pgr_temp->e;
						marker=1;	
					}
                    if(pgr_temp!=pgr)     //�ҵ����������ģ��Ͱѵ�ǰ��ַ��������ȥ������Ϊ��������������������
					{
                    pgr_temp2->next=pgr_temp->next;
					free(pgr_temp);
                    pgr_temp=pgr_temp2;
					}
					break;
				}
			}
			if(marker != 1)
			{
				enu=100; 
			}
		    if(enu== 0.0 )                        //��enuת��Ϊ result
			{
                                result=0.0;
			}
             else
			{
                                result=-1/(log(enu)/log(10));
              
			}
		    if(result>0 && result< 0.1)          //���ÿ��resultֵ��������浽ProteinRecord�ṹ��
			{
                                pr_temp->factor[j]=1;
                               	
			}
                     else if(result>=0.1 && result<0.2)
		   {
                               pr_temp->factor[j]=2;
                                  
		   }
                     else if(result>=0.2 && result<0.3)
		   {
                              pr_temp->factor[j]=3;

		   }
                     else if(result>=0.3 && result<0.4)
		   {
                               pr_temp->factor[j]=4;

		   }
                     else if(result>=0.4 && result<0.5)
		   {
                             pr_temp->factor[j]=5;

		   }
                     else if(result>=0.5 && result<0.6)
		   {
                             pr_temp->factor[j]=6;

		   }
                     else if(result>=0.6 && result<0.7)
		   {
                              pr_temp->factor[j]=7;

		   }
                     else if(result>=0.7 && result<0.8)
		   {
                             pr_temp->factor[j]=8;

		   }
                    else if(result>=0.8 && result<0.9)
		   {
                              pr_temp->factor[j]=9;

		   }
                     else if(result>=0.9 && result<1.0)
		   {
                               pr_temp->factor[j]=10;

		   }
                     else if(result==1.0)
		   {
                               pr_temp->factor[j]=11;

		   }
                     else if(result == -0.5)
		   {
                             pr_temp->factor[j]=12;

		   }
                     else if(result == 0.0)
		   {
                             pr_temp->factor[j]=13;


		   }
			
		}
		
                printf("marker %d proteins %d\n",i+1,pi_temp->proteinid);     

		if(i<(proteinnum-1))
		{
			pr_temp->next=new ProteinRecord;  //������һ���ڵ�
		    pr_temp=pr_temp->next;  //pr_tempָ����һ���ڵ�
			pi_temp=pi_temp->next;  //pi_tempָ����һ���ڵ�
		}
		else
            pr_temp->next=0;  //���һ���ڵ��nextָ�븳ֵΪ0��־�������
	}
//  ���ļ����ݵ��������������ˣ���������ѭ����ɾ�����������
    for(pgr_temp=pgr->next;pgr_temp!=0;pgr=pgr_temp,pgr_temp=pgr_temp->next)
	   free(pgr);
	for(gi_temp=gi->next;gi_temp!=0;gi=gi_temp,gi_temp=gi_temp->next)
	   free(gi);
    for(pi_temp=pi->next;pi_temp!=0;pi=pi_temp,pi_temp=pi_temp->next)
	    free(pi);
//���ProteinRecord �ṹ�������

	
	if((output1=fopen(OutputFileName1,"w"))==NULL)
	{
		printf( "�ļ�������� \n");		 
		return 1;
	}
	for(pr_temp2=pr;pr_temp2!=0;pr_temp2=pr_temp2->next)
	{  fprintf(output1,"\n%d ",pr_temp2->RecordNo); 
		for(h=0;h<GeneNum;h++)
	 fprintf(output1,"%d ",pr_temp2->factor[h]); 
	}
	fclose(output1);

	memset(OutputFileName, '\0', sizeof(OutputFileName));
	strcat(OutputFileName,OutputDir);
	if((output=fopen(OutputFileName,"w"))==NULL)
	{
		printf("TEST");
		printf( "�ļ�������� \n");		 
		return 1;
	}
	
	int pairCount = 0;
	for(h=0,pr_temp=pr;h<proteinnum;h++,pr_temp=pr_temp->next)
	{
	 	//	strcpy(OutputFileName,"./"); 
		// strcat(OutputFileName,"/");
		//_itoa(pr_temp->RecordNo, tmp, 10);  //������ת���ַ��� 
		// itoa(pr_temp->RecordNo, tmp, 10);  //������ת���ַ��� 
		//strcat(OutputFileName,tmp.c_str());
		//strcat(OutputFileName,OutputFileNameSuffix);
		
		//_itoa(pr_temp->RecordNo, tmp, 10);
		// itoa(pr_temp->RecordNo, tmp, 10);
	
		cf = cutoff;
		for(pr_temp2=pr_temp->next;(pr_temp2!=0);pr_temp2=pr_temp2->next)           //��ʽΪ H��a��+H��b��-H��ab��
		{
			entropy=JointEntropy(pr_temp,pr_temp2);
			mi=SelfEntropy(pr_temp)+SelfEntropy(pr_temp2)-entropy;
			if (mi >= cf) {
		   		//fprintf	(output,"%s\t%-12d\t%-5.4f\n", tmp.c_str(),
				//		pr_temp2->RecordNo,mi);
		   		fprintf	(output,"%-12d\t%-12d\t%-5.4f\n",pr_temp->RecordNo,
						pr_temp2->RecordNo,mi);
				printf("Get %d pairs: %-12d\t%-12d\n",(++pairCount), 
						pr_temp->RecordNo, pr_temp2->RecordNo); 
			//�ļ��е�ÿһ�о��� �����ʱ��1 ���ױ��2   ��Ӧ��miֵ
			}
		}
	}  
	fclose(output);
	
    for(pr_temp=pr->next;pr_temp!=0;pr=pr_temp,pr_temp=pr_temp->next)
           free(pr);
    




	return 0;
}

double SelfEntropy(ProteinRecord *P1)     //ͳ��һ����ÿ�����ֵ���ֵı��ʣ�ȡ��logֵ
{
	int i,j,k;
	double self=0;
	int count[MAX+1];
	double tmp;
	for(i=0;i<=MAX;i++)   count[i]=0;
	for(k=0;k<GeneNum;k++)           //�����int factor[81];�������Ĵ�С����ʵ���ǻ�����ĸ���
	{
		i=P1->factor[k];
		count[i]++;
	}
	for(j=0;j<=MAX;j++)
	{	
		if(count[j]!=0)
		{
			tmp=(double)count[j]/(double)GeneNum;     //���ֵ���ֵı���
			self+=tmp*log(tmp);			 //��ʽ  �� a*log��a�����
		}
	}
	self=0-self;
	return self;
}
double JointEntropy(ProteinRecord *P1,ProteinRecord *P2)   //ͳ�����������¶Ա��ֵ���ֵı��ʣ�ȡ��logֵ
{
	int i,j,k;                                     //��    1 2 3
	                                                //     1 2 3      ��ô1 1���ֵı��ʾ���1/3 
	double entropy=0;
	int count[MAX+1][MAX+1];
        double tmp;

	for(i=0;i<=MAX;i++) for(j=0;j<=MAX;j++) count[i][j]=0;

	
	for(k=0;k<GeneNum;k++) 
	{
		i=P1->factor[k];
		j=P2->factor[k];
		count[i][j]++;
	}
	for(i=0;i<=MAX;i++)
	for(j=0;j<=MAX;j++)
	{
		if(count[i][j]!=0)
		{
			tmp=(double)count[i][j]/(double)GeneNum;
			entropy+=tmp*log(tmp);			
		}
	}
	entropy=0-entropy;
	return entropy;
}
