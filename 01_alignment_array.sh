#!/usr/bin/bash
#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem-per-cpu=20G
#SBATCH --array=1-14
#SBATCH --time=02:00:00 # 2 hours
#SBATCH --mail-user=nmath020@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="run_alignment"
#SBATCH -p batch # Choose queue/partition from: intel, batch, highmem, gpu, short
#SBATCH --out logs/fastq_alignment.%a.log

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
  N=$1
fi
if [ -z $N ]; then
  echo "cannot run without a number provided either cmdline or --array in sbatch"
  exit
fi

GENOME=Nipponbare_IRGSP_1.0.sa
FASTQFOLDER=input
SAMPFILE=samples.csv

module load bwa
module load samtools

#mkdir -p ~/bigdata/Short_read_aligning
#cd ~/bigdata/Short_read_aligning
#mkdir -p fastq

#ln -s /bigdata/rice/ril2_analysis/coverage_plot/alignment/data/unmapped/*.fastq.gz fastq
#ln -s /bigdata/wesslerlab/shared/Rice/RILs_2021/analysis/genome/Nipponbare_IRGSP_1.0.sa # genome previously indexed
#ln -s /bigdata/wesslerlab/shared/Rice/RILs_2021/analysis/samples.csv

# Check if genome is indexed
if [ ! -f $GENOME.sa ]; then
   bwa index $GENOME
fi


IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read RILNAME FILEBASE
do
  LEFT=$(ls $FASTQFOLDER/$FILEBASE | sed -n 1p)
  RIGHT=$(ls $FASTQFOLDER/$FILEBASE | sed -n 2p)
  echo "$LEFT $RIGHT for $FASTQFOLDER/$FILEBASE"

#for acc in $(cat samples.csv)
#do
#	FWDREAD=fastq/${acc}_1.fastq.gz
#	REVREAD=fastq/${acc}_2.fastq.gz

	bwa mem -t $CPU $GENOME $LEFT $RIGHT > ${RILNAME}.sam
	samtools fixmate -O bam ${RILNAME}.sam ${RILNAME}_fixmate.bam
	samtools sort --threads $CPU -O BAM -o ${RILNAME}.bam ${RILNAME}_fixmate.bam
	samtools index ${RILNAME}.bam
done
