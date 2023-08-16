#!/usr/bin/bash
#SBATCH -p short -N 1 -n 16 --mem 4gb

module load bwa
module load samtools
CPU=16
#mkdir -p ~/bigdata/Short_read_aligning
#cd ~/bigdata/Short_read_aligning
#mkdir -p fastq
#ln -s /bigdata/rice/ril2_analysis/coverage_plot/alignment/input/*.fastq.gz fastq
ln -s /bigdata/wesslerlab/shared/Rice/RILs_2021/analysis/genome/Nipponbare_IRGSP_1.0
#ln -s /bigdata/rice/ril2_analysis/coverage_plot/alignment/acc.txt
GENOME=Nipponbare_IRGSP_1.0.sa
if [ ! -f $GENOME.sa ]; then
   bwa index $GENOME
fi

for acc in $(cat acc.txt)
do
	FWDREAD=input/${acc}-READ1.fastq.gz
	REVREAD=input/${acc}-READ2.fastq.gz

	bwa mem -t $CPU $GENOME $FWDREAD $REVREAD > ${acc}.sam
	samtools fixmate -O bam ${acc}.sam ${acc}_fixmate.bam
	samtools sort --threads $CPU -O BAM -o ${acc}.bam ${acc}_fixmate.bam
	samtools index ${acc}.bam
done
