### Use HOMER to generate Genome Browser Track

# Create "tag directories"
### do tag directories
for i in $(cat /mnt/BioScratch/danielasc/Redo_Rloops/indexes/merge_map.txt)
do
echo ${i} > TEMP
NEWNAME=$(cut -f1 -d: TEMP)


cat <<EOT >> /mnt/BioScratch/danielasc/Redo_Rloops/scripts/tag_dir_${NEWNAME}_PBS.sh

#!/bin/bash
#PBS -N tag_directories
#PBS -o /mnt/BioScratch/danielasc/Redo_Rloops/scripts/tag_dir_${NEWNAME}_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=4:00:00
#PBS -l mem=30gb


makeTagDirectory /mnt/BioScratch/danielasc/Redo_Rloops/tag_directories/${NEWNAME} -genome mm10 /mnt/BioScratch/danielasc/Redo_Rloops/bowtie/${NEWNAME}__accepted_hits_mm10_sorted_KEEP_PCR.bam

EOT

qsub /mnt/BioScratch/danielasc/Redo_Rloops/scripts/tag_dir_${NEWNAME}_PBS.sh

rm TEMP
done



### Merge tag directories replicates

cd /mnt/BioScratch/danielasc/Redo_Rloops/tag_directories

makeTagDirectory /mnt/BioScratch/danielasc/Redo_Rloops/tag_directories/Rloops_Dfl_PCR_RNASEH -genome mm10 -d 4WTRH_S21 Dfl1-mapR_S33 Dfl2-mapR_S35
makeTagDirectory /mnt/BioScratch/danielasc/Redo_Rloops/tag_directories/Rloops_DKO_PCR_RNASEH -genome mm10 -d 1DKORH_S18 DKO1-mapR_S29 DKO2-mapR_S31 

makeTagDirectory /mnt/BioScratch/danielasc/Redo_Rloops/tag_directories/Rloops_Dfl_PCR_Control -genome mm10 -d 3WTMN_S20  Dfl1-control_S34 Dfl2-control_S36
makeTagDirectory /mnt/BioScratch/danielasc/Redo_Rloops/tag_directories/Rloops_DKO_PCR_Control -genome mm10 -d 2DKOMN_S19 DKO1-control_S30 DKO2-control_S32

### Generate Genome Browser Track

makeMultiWigHub.pl MapR_20200610_keep_dup_merged mm10 -d Rloops_Dfl_PCR_RNASEH Rloops_DKO_PCR_RNASEH Rloops_Dfl_PCR_Control Rloops_DKO_PCR_Control -webdir /mnt/BioAdHoc/Groups/RaoLab/Vipul/20200610_TET_DKO_bcells -url http://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Vipul/20200610_TET_DKO_bcells
