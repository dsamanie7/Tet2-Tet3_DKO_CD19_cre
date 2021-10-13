### Call peaks

# Use MACS2 to call peaks


for i in $(cat /mnt/BioScratch/danielasc/20200610/indexes/bg4_input_rep2.txt)
do
echo ${i} > TEMP
CHIP=$(cut -f1 -d: TEMP)
INPUT=$(cut -f2 -d: TEMP)

cat <<EOT >> /mnt/BioScratch/danielasc/20200610/scripts/macs2_bg4_input_${CHIP}-${INPUT}.sh
#!/bin/bash
#PBS -N macs2
#PBS -o /mnt/BioScratch/danielasc/20200610/scripts/macs2_bg4_input_${CHIP}-${INPUT}.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=10:00:00
#PBS -l mem=20gb

 macs2 callpeak --keep-dup all  -t /mnt/BioScratch/danielasc/20200610/bowtie/${CHIP}_accepted_hits_mm10_sorted_m_PCR.bam -c /mnt/BioAdHoc/Groups/RaoLab/Vipul/3_6_19_DSC_VipulS_Chipseq-122471569/bowtie/${INPUT}_accepted_hits_mm10_sorted_m_PCR.bam -n /mnt/BioScratch/danielasc/20200610/macs2/${CHIP}-${INPUT}-peaks-rm-pcr  -g mm -p 0.0001 

EOT

qsub  /mnt/BioScratch/danielasc/20200610/scripts/macs2_bg4_input_${CHIP}-${INPUT}.sh

rm TEMP
done
 
