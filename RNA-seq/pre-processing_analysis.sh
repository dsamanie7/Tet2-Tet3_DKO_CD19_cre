### MAP with STAR


##### Do the mapping in one for loop instead of submitting several jobs at the time.

#!/bin/bash
#PBS -N star
#PBS -o /mnt/BioScratch/danielasc/RNA-seq_Vipul/scripts/star_all_samples_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=48:00:00
#PBS -l mem=30gb


for i in $(cat /mnt/BioScratch/danielasc/RNA-seq_Vipul/indexes/merge_fastq.txt)
do
echo ${i} > TEMP
ORIGINAL=$(cut -f1 -d: TEMP)
NEWNAME=$(cut -f2 -d: TEMP)

/home/danielasc/software/Linux_x86_64_static/STAR --runThreadN 8 -- genomeDir /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Sequence/STAR_ref_50/ --readFilesIn /mnt/BioScratch/danielasc/RNA-seq_Vipul/merged_fastq/${NEWNAME}.fastq --genomeLoad LoadAndRemove --outFilterMultimapNmax 1 --outFilterType BySJout --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 100000 --outFilterMismatchNmax 0  --genomeFileSizes /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Sequence/STAR_ref_50/chrLength.txt --outFileNamePrefix /mnt/BioScratch/danielasc/RNA-seq_Vipul/star_alignment/${NEWNAME}- 


rm TEMP
done

### Use featurecounts to get the raw counts

cd /mnt/BioScratch/danielasc/RNA-seq_Vipul/star_alignment
/share/apps/subread/subread-1.4.3-p1/featureCounts -g gene_name -a /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Annotation/Genes/genes.gtf -o /mnt/BioScratch/danielasc/RNA-seq_Vipul/featurecounts/Genes_featurecounts.txt -s 1  /mnt/BioScratch/danielasc/RNA-seq_Vipul/star_alignment/*-Aligned.out.sam

