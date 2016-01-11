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
#define MAX 13       //最大标记值
//#define GeneNum 127  //基因组个数
int GeneNum = 123;

#define LimitedNum 0.0001  //基因组个数

#include <string>
#include <vector>

// Added by Ziliang Qian in BIOSINO
void itoa(int value, std::string& buf, int base)
{
int i = 30;
buf = "";
for(; value && i ; --i, value /= base) buf = "0123456789abcdef"[value % base] + buf;
}

typedef struct ProteinRecord	//一条蛋白质纪录   此结构体用来存放三个输入文件处理后的结果，在JointEntropy  SelfEntropy两个函数中需要用到
{
	int RecordNo;				//蛋白质编号         例如10383750
	std::vector<int> factor;		//标准化以后的蛋白质对基因作用值 例如12	
	struct ProteinRecord *next;   //指向下一个节点，遍历链表时靠他索引下一个节点

public:
	ProteinRecord():factor(std::vector<int>(GeneNum,0)){};
	ProteinRecord& operator = (ProteinRecord& ref)
	{
		this->RecordNo=ref.RecordNo;
		this->factor=ref.factor;
		this->next=ref.next;
	}
} ProteinRecord	;

typedef struct ProteinGeneRecord	//一条蛋白质基因组纪录
{
	int ProteinNo;				//蛋白质编号         例如10383750
	int GenomeNo;               //基因组编号         例如20
	double e;		             //对应的e值         例如 3.0e-035
    struct ProteinGeneRecord *next;   //指向下一个节点，遍历链表时靠他索引下一个节点
} ProteinGeneRecord	;

typedef struct ProteinId	//一条蛋白质编号
{
	int proteinid;				//蛋白质编号         例如10383750
	struct ProteinId   *next;	  //指向下一个节点，遍历链表时靠他索引下一个节点
} ProteinId	;

typedef struct GenomeId	       //一条基因组编号
{
	int genomeid;				//基因组编号         例如20
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
	FILE *output1;     //用于输出ProteinRecord结构体

	char InputFileName[256]={'\0'}; //输入文件名
	char InputFileName1[256]={'\0'};
	char InputFileName2[256]={'\0'};
	
	 char OutputDir[256]={'\0'};
	 char OutputFileNameSuffix[]=".txt"; //输出文件名后缀
	char OutputFileName[256]={'\0'};  //输出二进制文件名
	char OutputFileName1[256]={'\0'};  // 用于输出ProteinRecord结构体


	int genomenum=0;          //纪录基因组总数
	int proteinnum=0;        // 纪录蛋白质总数
	int count=0;             //记录blastp.txt文件有多少行
	double enu=0;
	int marker;             //用与判断blastp.txt文件中是否有当前蛋白质编号和基因组编号的对应值
	double result=0;
	//对各个链表的头指针进行初始化
	ProteinRecord *pr=new ProteinRecord;
	ProteinGeneRecord *pgr=new ProteinGeneRecord;
    ProteinId   *pi=new ProteinId;
    GenomeId	*gi=new GenomeId;
	//为了遍历整个链表而加的临时变量
//////////////////////////////////////////////////////////////////////////////
	ProteinRecord *pr_temp,*pr_temp2;     //蛋白纪录
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
	
//	mkdir(OutputDir,0777);           //根据用户输出的目录名建一目录

	if((input=fopen(InputFileName,"r"))==NULL)
	{
     	printf( "文件读入错误 :-- %s\n", InputFileName);		 
     	return 1;
	}
	if((input1=fopen(InputFileName1,"r"))==NULL)
	{
     	printf( "文件读入错误 :-- %s\n", InputFileName1);		 
     	return 1;
	}
	if((input2=fopen(InputFileName2,"r"))==NULL)
	{
     	printf( "文件读入错误 :-- %s\n", InputFileName2);		 
     	return 1;
	}
	 
    //把gi.txt中的内容读入到pi指向的链表中
     pi_temp=pi;//把头节点指针赋给pi_temp
	while(1)                                      
	{	
		fscanf(input,"%d",&(pi_temp->proteinid));     //把每行的蛋白质编号存到 ProteinId 结构体
	    
	    if(feof(input)) {pi_temp->next=0; break;}
        proteinnum++;
		 pi_temp->next=new ProteinId;   //生成下一个节点，但是还没赋值,到下一个循环从文件中读取值
        pi_temp2=pi_temp;    //为了剔除文件中最后的一个值（此值是标识文件结尾的，所以应剔除）而加的临时变量
		pi_temp=pi_temp->next; //让pi_temp指向下一个节点
       
	}
    pi_temp2->next=0;
	free(pi_temp);  //剔除文件中最后的一个值

    gi_temp=gi;
	while(1)                                   //把每行的基因组编号存到 GenomeId 结构体
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
	while(1)                                  //把blastp.txt的内容存入  ProteinGeneRecord 结构体
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

    pr_temp=pr;//把头节点指针赋给pr_temp
	pi_temp=pi;//把头节点指针赋给pi_temp
	for(i=0;i<proteinnum;i++)
	{
	   pr_temp->RecordNo = pi_temp->proteinid;    // 把蛋白质编号赋给ProteinRecord结构体
	    
	  
		for(j=0,gi_temp=gi;j<genomenum;j++,gi_temp=gi_temp->next/*gi_temp指向下一个节点，实现数据遍历，下同*/)
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
                    if(pgr_temp!=pgr)     //找到满足条件的，就把当前地址从链表中去掉，因为其他的搜索不会在满足
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
		    if(enu== 0.0 )                        //把enu转化为 result
			{
                                result=0.0;
			}
             else
			{
                                result=-1/(log(enu)/log(10));
              
			}
		    if(result>0 && result< 0.1)          //标记每种result值，将结果存到ProteinRecord结构体
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
			pr_temp->next=new ProteinRecord;  //生成下一个节点
		    pr_temp=pr_temp->next;  //pr_temp指向下一个节点
			pi_temp=pi_temp->next;  //pi_temp指向下一个节点
		}
		else
            pr_temp->next=0;  //最后一个节点的next指针赋值为0标志链表结束
	}
//  存文件内容的三个链表用完了，以下三个循环是删除三个链表的
    for(pgr_temp=pgr->next;pgr_temp!=0;pgr=pgr_temp,pgr_temp=pgr_temp->next)
	   free(pgr);
	for(gi_temp=gi->next;gi_temp!=0;gi=gi_temp,gi_temp=gi_temp->next)
	   free(gi);
    for(pi_temp=pi->next;pi_temp!=0;pi=pi_temp,pi_temp=pi_temp->next)
	    free(pi);
//输出ProteinRecord 结构体的内容

	
	if((output1=fopen(OutputFileName1,"w"))==NULL)
	{
		printf( "文件输出错误 \n");		 
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
		printf( "文件输出错误 \n");		 
		return 1;
	}
	
	int pairCount = 0;
	for(h=0,pr_temp=pr;h<proteinnum;h++,pr_temp=pr_temp->next)
	{
	 	//	strcpy(OutputFileName,"./"); 
		// strcat(OutputFileName,"/");
		//_itoa(pr_temp->RecordNo, tmp, 10);  //把整数转成字符串 
		// itoa(pr_temp->RecordNo, tmp, 10);  //把整数转成字符串 
		//strcat(OutputFileName,tmp.c_str());
		//strcat(OutputFileName,OutputFileNameSuffix);
		
		//_itoa(pr_temp->RecordNo, tmp, 10);
		// itoa(pr_temp->RecordNo, tmp, 10);
	
		cf = cutoff;
		for(pr_temp2=pr_temp->next;(pr_temp2!=0);pr_temp2=pr_temp2->next)           //公式为 H（a）+H（b）-H（ab）
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
			//文件中的每一行就是 蛋白质编号1 蛋白编号2   对应的mi值
			}
		}
	}  
	fclose(output);
	
    for(pr_temp=pr->next;pr_temp!=0;pr=pr_temp,pr_temp=pr_temp->next)
           free(pr);
    




	return 0;
}

double SelfEntropy(ProteinRecord *P1)     //统计一行中每个标记值出现的比率，取负log值
{
	int i,j,k;
	double self=0;
	int count[MAX+1];
	double tmp;
	for(i=0;i<=MAX;i++)   count[i]=0;
	for(k=0;k<GeneNum;k++)           //这个是int factor[81];这个数组的大小，其实就是基因组的个数
	{
		i=P1->factor[k];
		count[i]++;
	}
	for(j=0;j<=MAX;j++)
	{	
		if(count[j]!=0)
		{
			tmp=(double)count[j]/(double)GeneNum;     //标记值出现的比率
			self+=tmp*log(tmp);			 //公式  对 a*log（a）求和
		}
	}
	self=0-self;
	return self;
}
double JointEntropy(ProteinRecord *P1,ProteinRecord *P2)   //统计两行中上下对标记值出现的比率，取负log值
{
	int i,j,k;                                     //如    1 2 3
	                                                //     1 2 3      那么1 1出现的比率就是1/3 
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
