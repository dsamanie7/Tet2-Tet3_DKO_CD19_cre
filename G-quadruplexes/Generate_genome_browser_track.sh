### Use HOMER to generate Genome Browser Track

# Create "tag directories"
# 

### do tag directories
for i in $(cat /mnt/BioScratch/danielasc/20200610/indexes/merge_map.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)


cat <<EOT >> /mnt/BioScratch/danielasc/20200610/scripts/tag_dir_${NEWNAME}_PBS.sh

#!/bin/bash
#PBS -N tag_directories
#PBS -o /mnt/BioScratch/danielasc/20200610/scripts/tag_dir_${NEWNAME}_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=4:00:00
#PBS -l mem=30gb


makeTagDirectory /mnt/BioScratch/danielasc/20200610/tag_directories/${NEWNAME} -genome mm10 /mnt/BioScratch/danielasc/20200610/bowtie/${NEWNAME}_accepted_hits_mm10_sorted_m_PCR.bam

EOT

qsub /mnt/BioScratch/danielasc/20200610/scripts/tag_dir_${NEWNAME}_PBS.sh

rm TEMP
done


### Merge the replicates of the G-quadruplexes

 makeTagDirectory /mnt/BioScratch/danielasc/20200610/tag_directories/G4_Dflx_merged -genome mm10 -d /mnt/BioAdHoc/Groups/RaoLab/Vipul/3_6_19_DSC_VipulS_Chipseq-122471569/tag_directories/Dflx-mBG4_S9 /mnt/BioScratch/danielasc/20200610/tag_directories/Dfl1-Gquad_S23
 makeTagDirectory /mnt/BioScratch/danielasc/20200610/tag_directories/G4_DKO_merged -genome mm10 -d /mnt/BioAdHoc/Groups/RaoLab/Vipul/3_6_19_DSC_VipulS_Chipseq-122471569/tag_directories/DKO-mBG4_S10 /mnt/BioScratch/danielasc/20200610/tag_directories/DKo1-G-quad_S24

### Generate Genome Browser Track with HOMER

 cd /mnt/BioScratch/danielasc/20200610/tag_directories
 makeMultiWigHub.pl BG4_merged_20200610 mm10 -d *_merged/ -webdir /mnt/BioAdHoc/Groups/RaoLab/Vipul/20200610_TET_DKO_bcells -url http://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Vipul/20200610_TET_DKO_bcells

 




