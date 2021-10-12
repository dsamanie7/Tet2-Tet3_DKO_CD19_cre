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

### 
