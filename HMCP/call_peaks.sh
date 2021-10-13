### Use MACS2 to call peaks

for i in $(cat /mnt/BioScratch/danielasc/HMCP_DKO/indexes/chip_input.txt)
do
echo ${i} > TEMP
CHIP=$(cut -f1 -d: TEMP)
INPUT=$(cut -f2 -d: TEMP)


cat <<EOT >> /mnt/BioScratch/danielasc/HMCP_DKO/scripts/rm_pcr_macs2_${CHIP}-${INPUT}.sh
#!/bin/bash
#PBS -N macs2
#PBS -o /mnt/BioScratch/danielasc/HMCP_DKO/scripts/rm_pcr_macs2_${CHIP}-${INPUT}_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=2:00:00
#PBS -l mem=4gb

 macs2 callpeak --keep-dup all  -t /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${CHIP}_bowtie1_accepted_hits_sorted_picard_mm10_short_M_pcr.bam -c /mnt/BioScratch/danielasc/HMCP_DKO/samfiles/${INPUT}_bowtie1_accepted_hits_sorted_picard_mm10_short_M_pcr.bam -n /mnt/BioScratch/danielasc/HMCP_DKO/macs2/${CHIP}-${INPUT}-peaks-rm-pcr  -g mm

EOT

qsub  /mnt/BioScratch/danielasc/HMCP_DKO/scripts/rm_pcr_macs2_${CHIP}-${INPUT}.sh

rm TEMP
done


#### merge the replicates of the dko and the dflx
mergePeaks dfl*.narrowPeak -venn venn_mergepeaks_dflx12.txt > mergepeaks_dflx12.txt
mergePeaks dko*.narrowPeak -venn venn_mergepeaks_dko12.txt > mergepeaks_dko12.txt

### get those peak regions that intersect in each condition
grep 'dfl-8038-hmCP_S1-input-dfl-hmCP_S5-peaks-rm-pcr_peaks.narrowPeak|dfl-8039-hmCP_S3-input-dfl-hmCP_S5-peaks-rm-pcr_peaks.narrowPeak' mergepeaks_dflx12.txt > intersection_mergepeaks_dflx12.txt
grep 'dko-8044-hmCP_S2-input-dko-hmCP_S6-peaks-rm-pcr_peaks.narrowPeak|dko-8045-hmCP_S4-input-dko-hmCP_S6-peaks-rm-pcr_peaks.narrowPeak' mergepeaks_dko12.txt > intersection_mergepeaks_dko12.txt

### get the union of each intersected peaks set
mergePeaks intersection_mergepeaks_d* -venn venn_intersection_mergepeaks_dflx12dko12.txt > intersection_mergepeaks_dflx12dko12.txt
