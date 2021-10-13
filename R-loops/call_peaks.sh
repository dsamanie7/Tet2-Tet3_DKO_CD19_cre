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

### merge the peaks from the replicates (per condition)
cd /mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input

mergePeaks 4WTRH_S21-3WTMN_S20-peaks-rm-pcr-broad-pval_peaks.broadPeak Dfl1-mapR_S33-Dfl1-control_S34-peaks-rm-pcr-broad-pval_peaks.broadPeak Dfl2-mapR_S35-Dfl2-control_S36-peaks-rm-pcr-broad-pval_peaks.broadPeak  -venn venn_mergepeaks_dfl123.txt > mergepeaks_dfl123.txt
mergePeaks 1DKORH_S18-2DKOMN_S19-peaks-rm-pcr-broad-pval_peaks.broadPeak DKO1-mapR_S29-DKO1-control_S30-peaks-rm-pcr-broad-pval_peaks.broadPeak DKO2-mapR_S31-DKO2-control_S32-peaks-rm-pcr-broad-pval_peaks.broadPeak  -venn venn_mergepeaks_dko123.txt > mergepeaks_dko123.txt

### select only those peaks that are intersecting on the replicates (per condition)
grep '4WTRH_S21-3WTMN_S20-peaks-rm-pcr-broad-pval_peaks.broadPeak|Dfl1-mapR_S33-Dfl1-control_S34-peaks-rm-pcr-broad-pval_peaks.broadPeak|Dfl2-mapR_S35-Dfl2-control_S36-peaks-rm-pcr-broad-pval_peaks.broadPeak' mergepeaks_dfl123.txt > intersect_mergepeaks_dfl123.txt
grep '1DKORH_S18-2DKOMN_S19-peaks-rm-pcr-broad-pval_peaks.broadPeak|DKO1-mapR_S29-DKO1-control_S30-peaks-rm-pcr-broad-pval_peaks.broadPeak|DKO2-mapR_S31-DKO2-control_S32-peaks-rm-pcr-broad-pval_peaks.broadPeak' mergepeaks_dko123.txt > intersect_mergepeaks_dko123.txt

### get the union of the intersected peaks in each condition 
mergePeaks intersect_mergepeaks_dfl123.txt intersect_mergepeaks_dko123.txt -venn venn_intersect_dfl_dko_123.txt > mergepeaks_intersect_dfl_dko_123.txt

### remove peaks that are in the "blacklist" regions in the genome
/home/danielasc/software/bedtools2/bin/intersectBed -b  /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Sequence/Blacklist/Blacklist.bed -a mergepeaks_intersect_dfl_dko_123.bed -v > mergepeaks_intersect_dfl_dko_123_rm_bl.bed
