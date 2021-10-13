### Map to the mm10 genome that contains the spiked-in sequence

for i in $(cat /mnt/BioScratch/danielasc/HMCP_DKO/indexes/merge.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >> /mnt/BioScratch/danielasc/HMCP_DKO/scripts/bowtie_mm10_${NEWNAME}.sh
#!/bin/bash
#PBS -N bowtie
#PBS -o /mnt/BioScratch/danielasc/HMCP_DKO/scripts/bowtie_mm10_${NEWNAME}.sh.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=6:00:00
#PBS -l mem=20gb

/mnt/apps/bowtie/bowtie-1.1.2/bowtie -S -p 3 --un /mnt/BioScratch/danielasc/HMCP_DKO/merge_fastq/${NEWNAME}_unaligned_lambda_short.fastq /mnt/BioScratch/bowtie1/index/mm10r_random_Phague/genome /mnt/BioScratch/danielasc/HMCP_DKO/merge_fastq/${NEWNAME}.fastq /mnt/BioScratch/danielasc/HMCP_DKO/bowtie/${NEWNAME}_accepted_hits_lambda_short.sam 2> /mnt/BioScratch/danielasc/HMCP_DKO/bowtie/${NEWNAME}_filter.bowtie_lambda_short.err 

EOT

rm TEMP

qsub /mnt/BioScratch/danielasc/HMCP_DKO/scripts/bowtie_mm10_${NEWNAME}.sh

done

### do the filtering for those reads that mapped to the mc or hmC

for i in $(cat /mnt/BioScratch/danielasc/HMCP_DKO/indexes/merge.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >>  /mnt/BioScratch/danielasc/HMCP_DKO/scripts/filter_spike-in_${NEWNAME}_PBS.sh


#!/bin/bash
#PBS -N filter_BSMAP
#PBS -o   /mnt/BioScratch/danielasc/HMCP_DKO/scripts/filter_spike-in_${NEWNAME}_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=12:00:00
#PBS -l mem=10gb

grep    chrPhagueLambda /mnt/BioScratch/danielasc/HMCP_DKO/bowtie/${NEWNAME}_accepted_hits_lambda_short.sam > /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.sam
samtools view -S -h -L /mnt/BioAdHoc/Groups/RaoLab/Vipul/CMSIP_20180411/bsmap/genome/C_Lambda.bed /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.sam   | grep -v chr[1-9MYX][1-9]* > /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.C.sam 
samtools view -S -h -L /mnt/BioAdHoc/Groups/RaoLab/Vipul/CMSIP_20180411/bsmap/genome/mC_Lambda.bed /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.sam  | grep -v chr[1-9MYX][1-9]* > /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.mC.sam 
samtools view -S -h -L /mnt/BioAdHoc/Groups/RaoLab/Vipul/CMSIP_20180411/bsmap/genome/hmC_Lambda.bed /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.sam | grep -v chr[1-9MYX][1-9]* > /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}.Lambda.hmC.sam 

grep -v chrPhagueLambda /mnt/BioScratch/danielasc/HMCP_DKO/bowtie/${NEWNAME}_accepted_hits_lambda_short.sam  >   /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_accepted_hits_mm10_short.sam

EOT

qsub  /mnt/BioScratch/danielasc/HMCP_DKO/scripts/filter_spike-in_${NEWNAME}_PBS.sh

rm TEMP
done


#### Sort files and remove PCR duplicates


for i in $(cat /mnt/BioScratch/danielasc/HMCP_DKO/indexes/merge.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >>  /mnt/BioScratch/danielasc/HMCP_DKO/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_PBS.sh

#!/bin/bash
#PBS -N sort
#PBS -o  /mnt/BioScratch/danielasc/HMCP_DKO/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=24:00:00
#PBS -l mem=20gb

/share/apps/java/jdk1.8.0_102/bin/java -jar  /share/apps/picard-tools/picard-tools-2.7.1/picard.jar SortSam INPUT=/mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_accepted_hits_mm10_short.sam OUTPUT=/mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_bowtie1_accepted_hits_sorted_picard_mm10_short.sam SORT_ORDER=coordinate
/share/apps/java/jdk1.8.0_102/bin/java -jar  /share/apps/picard-tools/picard-tools-2.7.1/picard.jar  MarkDuplicates INPUT=/mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_bowtie1_accepted_hits_sorted_picard_mm10_short.sam OUTPUT=/mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_bowtie1_accepted_hits_sorted_picard_mm10_short_M_pcr.sam M=/mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_bowtie1_metrics_accepted_hits.sorted_M_pcr_mm10_short.txt REMOVE_DUPLICATES=true
samtools view -bS /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_bowtie1_accepted_hits_sorted_picard_mm10_short_M_pcr.sam > /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${NEWNAME}_bowtie1_accepted_hits_sorted_picard_mm10_short_M_pcr.bam

EOT

qsub /mnt/BioScratch/danielasc/HMCP_DKO/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_PBS.sh

rm TEMP
done



