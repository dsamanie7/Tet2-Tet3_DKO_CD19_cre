### Use MIXCR to get the BCR from RNA-seq

for i in $(cat /mnt/BioScratch/danielasc/RNA-seq_Vipul/indexes/merge_fastq.txt)
do
echo ${i} > TEMP

ORIGINAL=$(cut -f1 -d: TEMP)
NEWNAME=$(cut -f2 -d: TEMP)

cat <<EOT >>  /mnt/BioScratch/danielasc/RNA-seq_Vipul/scripts/MIXCR_${NEWNAME}_PBS.sh

#!/bin/bash
#PBS -N MIXCR
#PBS -o /mnt/BioScratch/danielasc/RNA-seq_Vipul/scripts/MIXCR_${NEWNAME}_PBS.out
#PBS -j oe
#PBS -m abe
#PBS -M danielasc@lji.org
#PBS -q rao-exclusive
#PBS -l walltime=4:00:00
#PBS -l mem=10gb

#ALIGNMENT

mixcr align -c IG -s mmu -p rna-seq -OallowPartialAlignments=true  /mnt/BioScratch/danielasc/RNA-seq_Vipul/merged_fastq/${NEWNAME}.fastq /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Alignment/${NEWNAME}-alignments.vdjca

####ASSEMBLE EVERYTHING

mixcr assemblePartial -r /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-assemblepartial1_report.txt /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Alignment/${NEWNAME}-alignments.vdjca /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-alignments_rescued1.vdjca 
mixcr assemblePartial -r /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-assemblepartial2_report.txt /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-alignments_rescued1.vdjca /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-alignments_rescued2.vdjca 
mixcr extendAlignments -r /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-extendalignments_report.txt /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-alignments_rescued2.vdjca /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-alignments_rescued2_extended.vdjca
mixcr assemble -r /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-assemble_report.txt /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-alignments_rescued2_extended.vdjca /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-clones.clns

#EXPORT

mixcr exportClones --preset min -fraction -targets -vHits -dHits -jHits -vAlignments -dAlignments -jAlignments  /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Assemble/${NEWNAME}-clones.clns /mnt/BioScratch/danielasc/RNA-seq_Vipul/BCR/Export/${NEWNAME}-clones.txt

EOT

qsub /mnt/BioScratch/danielasc/RNA-seq_Vipul/scripts/MIXCR_${NEWNAME}_PBS.sh

rm TEMP

done


