### MAPPING

# map_g4.txt contains the sample name

for i in $(cat /mnt/BioScratch/danielasc/G4_multimappers/indexes/map_g4.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >> /mnt/BioScratch/danielasc/G4_multimappers/scripts/bowtie_mm10plusspikes_${NEWNAME}.sh
#!/bin/bash
#PBS -N bowtie
#PBS -o /mnt/BioScratch/danielasc/G4_multimappers/scripts/bowtie_mm10plusspikes_${NEWNAME}.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=24:00:00
#PBS -l mem=40gb
#PBS -l nodes=1:ppn=8

/mnt/apps/bowtie/bowtie-1.1.2/bowtie -p 8 /mnt/BioAdHoc/Groups/RaoLab/Vipul/Bowtie1_index_spikeins_BG4/genome_w_spike -1 /mnt/BioScratch/danielasc/G4_multimappers/merged_fastq/${NEWNAME}_R1.fastq -2 /mnt/BioScratch/danielasc/G4_multimappers/merged_fastq/${NEWNAME}_R2.fastq -S /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_spikein.sam 2> /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_filter.bowtie_mm10_spikein.err

EOT

qsub /mnt/BioScratch/danielasc/G4_multimappers/scripts/bowtie_mm10plusspikes_${NEWNAME}.sh

rm TEMP

done

### ### filter out all reads that mapped in the spike in

for i in $(cat /mnt/BioScratch/danielasc/G4_multimappers/indexes/map_g4.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >>  /mnt/BioScratch/danielasc/G4_multimappers/scripts/bw1_sort_picard_bowtie_${NEWNAME}_keep_PBS.sh

#!/bin/bash
#PBS -N sort
#PBS -o  /mnt/BioScratch/danielasc/G4_multimappers/scripts/bw1_sort_picard_bowtie_${NEWNAME}_spike_keep_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=40:00:00
#PBS -l mem=20gb
#PBS -l nodes=1:ppn=2


grep chrSpikeq /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_spikein.sam  > /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}.pc52.sam
samtools view -S -h -L /mnt/BioAdHoc/Groups/RaoLab/Vipul/3_6_19_DSC_VipulS_Chipseq-122471569/index/G4_sequence.bed /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}.pc52.sam  | grep -v chr[1-9MYX][1-9]* > /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}.G4_spikein.sam 

grep -v chrSpikeq /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_spikein.sam   >   /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10.sam

samtools view -bS /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10.sam > /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10.bam

EOT

qsub /mnt/BioScratch/danielasc/G4_multimappers/scripts/bw1_sort_picard_bowtie_${NEWNAME}_keep_PBS.sh

rm TEMP
done



### sort and filter out PCR duplicates
for i in $(cat /mnt/BioScratch/danielasc/G4_multimappers/indexes/map_g4.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)

cat <<EOT >>  /mnt/BioScratch/danielasc/G4_multimappers/scripts/bw1_sort_picard_bowtie_spike_${NEWNAME}_spike_PBS.sh

#!/bin/bash
#PBS -N sort
#PBS -o  /mnt/BioScratch/danielasc/G4_multimappers/scripts/bw1_sort_picard_bowtie_spike_${NEWNAME}_spike_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=40:00:00
#PBS -l mem=20gb

/share/apps/java/jdk1.8.0_102/bin/java -jar  /share/apps/picard-tools/picard-tools-2.7.1/picard.jar SortSam INPUT=/mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10.sam OUTPUT=/mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_sorted.sam SORT_ORDER=coordinate
/share/apps/java/jdk1.8.0_102/bin/java -jar  /share/apps/picard-tools/picard-tools-2.7.1/picard.jar  MarkDuplicates INPUT=/mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_sorted.sam  OUTPUT=/mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_m_PCR.sam M=/mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_m_PCR_file.txt REMOVE_DUPLICATES=true
samtools view -bS /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_m_PCR.sam > /mnt/BioScratch/danielasc/G4_multimappers/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_m_PCR.bam

EOT

qsub /mnt/BioScratch/danielasc/G4_multimappers/scripts/bw1_sort_picard_bowtie_spike_${NEWNAME}_spike_PBS.sh

rm TEMP
done

 
