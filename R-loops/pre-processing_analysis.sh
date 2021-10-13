### Map with MACS2

# merge_map.txt contains the R-loops sample name

for i in $(cat /mnt/BioScratch/danielasc/20200610/indexes/merge_map.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >> /mnt/BioScratch/danielasc/20200610/scripts/bowtie_mm10_${NEWNAME}.sh
#!/bin/bash
#PBS -N bowtie
#PBS -o /mnt/BioScratch/danielasc/20200610/scripts/bowtie_mm10_${NEWNAME}.sh.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=12:00:00
#PBS -l mem=20gb

/mnt/apps/bowtie/bowtie-1.1.2/bowtie -p 3  /mnt/BioAdHoc/Groups/RaoLab/Bioinformatics/apps/Mus_musculus/UCSC/mm10/BowtieIndex/genome -1 /mnt/BioScratch/danielasc/20200610/merged_fastq/${NEWNAME}_R1.fastq -2 /mnt/BioScratch/danielasc/20200610/merged_fastq/${NEWNAME}_R2.fastq -S /mnt/BioScratch/danielasc/20200610/bowtie/${NEWNAME}_accepted_hits_mm10_spikein.sam 2> /mnt/BioScratch/danielasc/20200610/bowtie/${NEWNAME}_filter.bowtie_mm10_spikein.err 

EOT

rm TEMP

qsub /mnt/BioScratch/danielasc/20200610/scripts/bowtie_mm10_${NEWNAME}.sh

done

### Keep PCR duplicates

for i in $(cat /mnt/BioScratch/danielasc/Redo_Rloops/indexes/merge_map.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >>  /mnt/BioScratch/danielasc/Redo_Rloops/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_keep_PBS.sh

#!/bin/bash
#PBS -N sort
#PBS -o  /mnt/BioScratch/danielasc/20200610/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_keep_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=24:00:00
#PBS -l mem=40gb

/share/apps/java/jdk1.8.0_102/bin/java -jar  /share/apps/picard-tools/picard-tools-2.7.1/picard.jar SortSam INPUT=/mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}_accepted_hits_mm10.sam OUTPUT=/mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}_accepted_hits_mm10_sorted.sam SORT_ORDER=coordinate
/share/apps/java/jdk1.8.0_102/bin/java -jar  /share/apps/picard-tools/picard-tools-2.7.1/picard.jar  MarkDuplicates INPUT=/mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}_accepted_hits_mm10_sorted.sam  OUTPUT=/mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_KEEP_PCR.sam M=/mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_m_PCR_file.txt REMOVE_DUPLICATES=false
samtools view -bS /mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_KEEP_PCR.sam > /mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}__accepted_hits_mm10_sorted_KEEP_PCR.bam

EOT

qsub /mnt/BioScratch/danielasc/Redo_Rloops/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_keep_PBS.sh

rm TEMP
done

