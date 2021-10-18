### Call peaks

# Use MACS2 to call peaks
# bg4_input_rep.txt will have a ":" separated file with the first column being the name of the ChIP-seq sample and the second column being the name of the input sample

for i in $(cat /mnt/BioScratch/danielasc/20200610/indexes/bg4_input_rep.txt)
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
 
### Get those peaks that are intersecting in each condition 

mergePeaks /mnt/BioScratch/danielasc/20200610/macs2/Dfl1-Gquad_S23-Dflx-Input_S6-peaks-rm-pcr_peaks.narrowPeak /mnt/BioScratch/danielasc/20200610/macs2/Dflx-mBG4_S9-Dflx-Input_S6-peaks-rm-pcr_peaks.narrowPeak -venn /mnt/BioScratch/danielasc/20200610/Gquad/venn_mergepeaks_dflx12.txt > /mnt/BioScratch/danielasc/20200610/Gquad/mergepeaks_dflx12.txt
mergePeaks /mnt/BioScratch/danielasc/20200610/macs2/DKo1-G-quad_S24-DKO-Input_S7-peaks-rm-pcr_peaks.narrowPeak /mnt/BioScratch/danielasc/20200610/macs2/DKO-mBG4_S10-DKO-Input_S7-peaks-rm-pcr_peaks.narrowPeak -venn /mnt/BioScratch/danielasc/20200610/Gquad/venn_mergepeaks_dko12.txt > /mnt/BioScratch/danielasc/20200610/Gquad/mergepeaks_dko12.txt

cd /mnt/BioScratch/danielasc/20200610/Gquad
grep '/mnt/BioScratch/danielasc/20200610/macs2/Dfl1-Gquad_S23-Dflx-Input_S6-peaks-rm-pcr_peaks.narrowPeak|/mnt/BioScratch/danielasc/20200610/macs2/Dflx-mBG4_S9-Dflx-Input_S6-peaks-rm-pcr_peaks.narrowPeak' mergepeaks_dflx12.txt > intersection_mergepeaks_dflx12.txt
grep '/mnt/BioScratch/danielasc/20200610/macs2/DKo1-G-quad_S24-DKO-Input_S7-peaks-rm-pcr_peaks.narrowPeak|/mnt/BioScratch/danielasc/20200610/macs2/DKO-mBG4_S10-DKO-Input_S7-peaks-rm-pcr_peaks.narrowPeak' mergepeaks_dko12.txt > intersection_mergepeaks_dko12.txt

### Get the union of the intersected peaks 

cd /mnt/BioScratch/danielasc/20200610/Gquad

mergePeaks intersection_mergepeaks_dko12.txt intersection_mergepeaks_dflx12.txt -venn /mnt/BioScratch/danielasc/20200610/Gquad/venn_mergepeaks_intersection_dko12_dflx12.txt > /mnt/BioScratch/danielasc/20200610/Gquad/mergepeaks_intersection_dko12_dflx12.txt
grep 'intersection_mergepeaks_dko12.txt|intersection_mergepeaks_dflx12.txt' mergepeaks_intersection_dko12_dflx12.txt > shared_dflx12_dko12.txt
grep 'intersection_mergepeaks_dflx12.txt' mergepeaks_intersection_dko12_dflx12.txt |grep -v 'intersection_mergepeaks_dko12.txt|intersection_mergepeaks_dflx12.txt' > unique_dflx12.txt
grep 'intersection_mergepeaks_dko12.txt' mergepeaks_intersection_dko12_dflx12.txt |grep -v 'intersection_mergepeaks_dko12.txt|intersection_mergepeaks_dflx12.txt'> unique_dko12.txt

 #### REMOVE BLACKLISTED REGIONS
 cd /mnt/BioScratch/danielasc/20200610/Gquad

 /home/danielasc/software/bedtools2/bin/intersectBed -b  /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Sequence/Blacklist/Blacklist.bed -a unique_dflx12.bed -v > unique_dflx12_bl_rm.bed
 /home/danielasc/software/bedtools2/bin/intersectBed -b  /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Sequence/Blacklist/Blacklist.bed -a unique_dko12.bed -v > unique_dko12_bl_rm.bed
 /home/danielasc/software/bedtools2/bin/intersectBed -b  /mnt/BioAdHoc/Groups/RaoLab/Edahi/01.Genomes/Mus_musculus/UCSC/mm10/Sequence/Blacklist/Blacklist.bed -a shared_dflx12_dko12.bed -v > shared_dflx12_dko12_bl_rm.bed

cat unique_dflx12_bl_rm.bed unique_dko12_bl_rm.bed shared_dflx12_dko12_bl_rm.bed /mnt/BioScratch/danielasc/20200610/Gquad/union_corrected_regions.bed
