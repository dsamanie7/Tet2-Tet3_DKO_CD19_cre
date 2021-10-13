### Call peaks

# Use MACS2 to call peaks
# pcr_keep_chip_input will have a ":" separated file with the first column being the name of the MAPR-RNaseH sample and the second column being the name of the MNase sample

for i in $(cat /mnt/BioScratch/danielasc/Redo_Rloops/indexes/pcr_keep_chip_input.txt)
do
echo ${i} > TEMP
CHIP=$(cut -f1 -d: TEMP)
INPUT=$(cut -f2 -d: TEMP)


cat <<EOT >> /mnt/BioScratch/danielasc/Redo_Rloops/scripts/macs2_broad_${CHIP}-${INPUT}.sh
#!/bin/bash
#PBS -N macs2
#PBS -o /mnt/BioScratch/danielasc/Redo_Rloops/scripts/macs2_broad_${CHIP}-${INPUT}.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=10:00:00
#PBS -l mem=20gb

 macs2 callpeak --keep-dup all  -t /mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${CHIP}__accepted_hits_mm10_sorted_KEEP_PCR.bam -c /mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${INPUT}__accepted_hits_mm10_sorted_KEEP_PCR.bam  -n /mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input/${CHIP}-${INPUT}-peaks-rm-pcr-broad-pval --broad --broad-cutoff 0.1  -g mm

EOT

qsub  /mnt/BioScratch/danielasc/Redo_Rloops/scripts/macs2_broad_${CHIP}-${INPUT}.sh

rm TEMP
done
