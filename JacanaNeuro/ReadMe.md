Notes on Mapping project:

dependencies for this project: Miniconda, hisat2, samtools, trimmomatic, RSeQC, bedops, subread, agat, DESeq.

Step 1: Copied over all data from the IU lims
	wget --user krosvall --password YeTp5LSt https://lims.cgb.indiana.edu/outbox/RosvallLab/GSF2960/run1/archive-GSF2960.tar
Step 2: I put each of the tar files in their own diretory to prevent overwriting of duplicates and untarred
	tar -xvf filename.tar
Step 3: I extracted the sequencing file names to get an understanding of samples, tissues and suplicates
	find -name \*.gz -printf "%f\n" > fileNames.txt
Step 4: After examining I, I removed files with file names containing "Brain", "Blood" or "Gonad ". 
	mv **/*Blood*.gz ../extra/rep1
Step 5: Naming scheme discrepancy fix in "run5"
	rename 'GSF2960-Rosvall-' '' *.gz
Step 6: I concatenated duplicate gz files since we want to treat each gz file as a single individual sample
	cat ./run3/GSF2960-NOF1-POA_S52_R1_001.fastq.gz >> ./run1/GSF2960-NOF1-POA_S52_R1_001.fastq.gz
	rm ./run3/GSF2960-NOF1-POA_S52_R1_001.fastq.gz
Step 7: Upon further inspection we have sample replicates so we are also going to merge these files.
	I made a script for this called "catScript.sh". Honestly you should modify this to complete step 6 as well 
	This will take 5+ min to run
Step 8: I installed MiniConda on the local account and used that to install any other dependencies (i.e. hisat2, samtools, etc)
	conda install -c bioconda PKGNAME
Step 9: Now that we have all of our files of interest we can evaluate the quality with fastQC.
	Run script "fastqc.sh"
Step 10: After a brief look at some of the fastQ files it appears most of our reads are high quality. There are some issues with bp 35 so we will still run through trimmomatic with very loose parameters just to see what happens.
	Run script trim.sh
	My version of loose parameters is Trailing:28, SlidingWindow:4:15 and MinLength:32
	avg number of reads ~5M and avg retained was 93%
Step 11: Determine the strandedness of your data
	#Figure out the strandedness of your sequencing data. Run HISAT2 on ONE pair of fastq files with the unstranded option set to create your bam file. This lowkey takes a long time (try using -p so you can use more threads)
	part 1: hisat2 -x ../HISAT/jacana -1 ../trimOut/paired/GSF2960-NOF10-POA_S17_R1_paired.fq.gz -2 ../trimOut/paired/GSF2960-NOF10-POA_S17_R2_paired.fq.gz -p 8 | samtools sort -o ../HISAT/test.bam
	#convert our gff file to a bed file
	part 2: gff2bed < ../assembly/jacana_from_gallus_gallus.gff >>  jacana_gallus.bed
	#we will now take our bam output and use it to evaluate strandedness using RSeQC
	part 3: python3 ../../RSeQC-5.0.1/scripts/infer_experiment.py -r jacana_gallus.bed -i test.bam > strandInfo.txt
Step 12: Map your reads to the ruff/chicken annotated genomes using hisat2
	#build reference index. This takes ~30 min
	part 1: hisat2-build ../genome/Jacana.2cell.hap1.fa jacana
	#Run HISAT2 (we'll do a quick test before we do our for loop)
	part 2 (TEST): hisat2 --rna-strandness RF -x ./jacana -1 ../trimOut/paired/GSF2960-NOF10-POA_S17_R1_paired.fq.gz -2 ../trimOut/paired/GSF2960-NOF10-POA_S17_R2_paired.fq.gz -p 8 | samtools sort -o ./demo_trimmed.bam
	part 2: nohup bash hisatScript.sh &
	# NOTE!! we are aligning over 200 PE files so this script will take a LONG time to run (approx. 13 hours)
Step 13: Use featureCounts to create your count matrix!
	# We need to convert our gff to a compatible gtf file format. This takes ~8 min
	part 1: agat_convert_sp_gff2gtf.pl --gff jacana_from_gallus_gallus.gff -o jacana_from_gallus_gallus.gtf
	#run featureCounts on all of our bam files!
	part 2 (test): featureCounts -s 2 -a jacana_from_gallus_gallus_relaxed.gtf -o ./count_prac.txt ./GSF2960-NOF10-POA_S17_.bam
	part 2: featureCounts -s 2 -a jacana_from_gallus_gallus.gtf -o ./count_matrix.txt -p -T 10 *.bam
	# NOTE: what is strange about this command is that only ~50% of our reads are aligning? I will play with it... There is information about why reads were excluded in count_matrix.txt.summary

The following steps were completed on my local computer and not the HPCC

Step 14: Collapse columns into individuals (removing technical replicates)
	# collapseReplicates from DESeq
	part 1: download the count matrix and read it into R
	part 2: collapse technical replicates using the R studio notebook collapseReplicates.R
Step 15: Add in a column for gene names next to gene ID:
	use python script getIDs.py (you will need access to your csv file and gtf file for this script to run)
