export PATH=/share/apps/R/3.1.0/bin:/share/apps/python/python-3.4.6/bin:/share/apps/python/python-2.7.13/bin:/share/apps/perl/perl-5.18.1-threaded/bin/:/share/apps/gcc/6.3/bin:/mnt/BioApps/pigz/latest/bin:/share/apps/bin:/usr/local/maui/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/opt/stack/bin:/share/apps/java/latest/bin:/share/apps/bowtie/bowtie2-2.1.0:/share/apps/bowtie/bowtie-1.1.2:/usr/local/cuda/bin:/share/apps/dos2unix/latest/bin:/share/apps/bedtools/bin:/share/apps/HOMER/bin
printf "PATH Used:\n$PATH\n\n"
unset PYTHONPATH

#Variables:
    fastqc=/Bioinformatics/apps/FastQC/FastQC-0.11.2/fastqc
   MarkDup=/Bioinformatics/apps/picard-tools/picard-tools-1.94/MarkDuplicates.jar
     bsmap=/home/edahi/download/code/bsmap-2.90/bsmap
   mm10bwa=/home/edahi/download/genome/mm10/bwa/index/mm10_random/mm10.fa
    Mratio=/home/edahi/usr/bin/methratio.py
    genome=/home/edahi/download/genome/mm10r_phage/genome.fa
   radmeth=/mnt/BioAdHoc/Groups/RaoLab/Edahi/00.Scripts/01.Downloaded/methpipe-3.4.2/bin/radmeth
     bg2bw=/mnt/BioAdHoc/Groups/RaoLab/Edahi/00.Scripts/Bash/bedGraph2BigWig.sh
     Mcall=/share/apps/moab/bin/mcall
       sam=/usr/bin/samtools
      samF=/usr/bin


# Folders:
VennDiagrams=/BioScratch/danielasc/VennDiagrams
   DeepTools=/BioScratch/danielasc/DeepTools
     surname=WGBS-dfl-1_S1
        name=WGBS-dfl-1
       Ebash=/mnt/BioAdHoc/Groups/RaoLab/Edahi/00.Scripts/Bash
       Eperl=/mnt/BioAdHoc/Groups/RaoLab/Edahi/00.Scripts/perl
     Project=/mnt/BioAdHoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622
        Jobs=$Project/Jobs
    softlink=$Project/01.Data
     mapping=$Project/02.Mapping
    MethCall=$Project/10.MethCall_NoDup
          MT=$Project/11.Master_NoDup
     RadMeth=$Project/12.RadMeth_NoDup
          BW=$Project/13.BigWigs_NoDup
      FASTQC=$Project/FASTQC
    download=/mnt/BioScratch/danielasc/20200622/fastq
        TEMP=/mnt/BioScratch/edahi
        temp=/mnt/BioScratch/edahi/DanielaSamaniego/20200622

# Generate Directories Framework:
mkdir -p $softlink $mapping $MethCall $MT $FASTQC $temp

# START LOOP
for name in WGBS-dfl-1 WGBS-Dfl-2 WGBS-Dko-1 WGBS-DKO-2; do
  # >>>>>> Merge files from same lane:
  cat $download/${surname}*L*_R1*fastq  > $temp/${name}_R1.fastq
  cat $download/${surname}*L*_R2*fastq  > $temp/${name}_R2.fastq
  
  # >>>>>> Create Softlinks for WGBS-dfl-1
  ln -s $temp/${name}_R1.fastq ${softlink}/WGBS-dfl-1_R1.fastq
  ln -s $temp/${name}_R2.fastq ${softlink}/WGBS-dfl-1_R2.fastq
  
  # >>>>>> FASTQC for downloaded files
  $fastqc ${softlink}/${name}_R1.fastq --outdir=$FASTQC &
  $fastqc ${softlink}/${name}_R2.fastq --outdir=$FASTQC &
  
  # >>>>>> Mapping
  cd       $mapping/
  $bsmap -a $temp/${name}_R1.fastq -b $temp/${name}_R2.fastq -d $genome -o $temp/${name}.unsorted.bam -v 15 -w 3 -p 8 -S 1921 -q 20 -r 1 -R -V 2 > $mapping/${name}_bsmap_log.txt
  
  
  # >>>>>> Separate Lambda, phix and GRCh38 Genome mapping results.
  $sam sort -@ 8 $temp/${name}.unsorted.bam  $mapping/${name}
  $sam index     $mapping/${name}.bam
  $sam view -b   $mapping/${name}.bam chrPhagueLambda                                  > $mapping/${name}.Lambda.bam
  $sam view      $mapping/${name}.bam | grep chr | $sam view -b -ht ${genome}.fai -  > $mapping/${name}.mm10.sam
  $sam index     $mapping/${name}.Lambda.bam
  
  # >>>>>> Correct extension
  mv $mapping/${name}.mm10.sam $mapping/${name}.mm10.bam
  
  # >>>>>> Bisulfite treatment efficiency
  $Mcall -m $mapping/${name}.Lambda.bam -r $genome -p 8 --skipRandomChrom 1 --statsOnly 1
  $Mcall -m $mapping/${name}.mm10.bam   -r $genome -p 8 --skipRandomChrom 1 --statsOnly 1
  
  # >>>>>> Remove Duplicates	
  java -jar $MarkDup INPUT=$mapping/${name}.mm10.bam OUTPUT=$mapping/${name}.mm10.MarkDup.bam REMOVE_DUPLICATES=true  ASSUME_SORTED=true METRICS_FILE=$mapping/${name}.mm10.PicardMetrics.txt
  
  # >>>>>> Methylation Calls
  $Mratio -o $MethCall/${name}.Lambda.meth  -d $genome  -c chrPhagueLambda -s $samF  -g  -i "correct"  -x CG          $mapping/${name}.Lambda.bam 2>&1 > $MethCall/${name}.Lambda.meth.log
  $Mratio -o $MethCall/${name}.mm10.meth    -d $genome                     -s $samF  -g  -i "correct"  -x CG,CHG,CHH  $mapping/${name}.mm10.MarkDup.bam   2>&1 > $MethCall/${name}.mm10.meth.log
  
  # >>>>>> CG context Methylation calls
  awk -v OFS="\t" -v FS="\t" '{if(NR==1) {print $1,$2,"End",$7,$8; next} if($4=="CG") {print $1,$2,$2+1,$7,$8} }' $MethCall/${name}.mm10.meth > $MethCall/${name}.mm10.CG.meth
done

# >>> Run MasterTable
# # # # # # ## # # # # 
# # # # # # ## # # # # 
# # # # # # # YOU NEED TO ADD MY MASTER TABLE SCRIPT USED BELOW
# # # # # # ## # # # # 
# # # # # # ## # # # # 
# # # # # # ## # # # # 
$Eperl/MasterTable_CT.pl \
 -file $MethCall/WGBS-dfl-1.mm10.CG.meth,$MethCall/WGBS-Dfl-2.mm10.CG.meth,$MethCall/WGBS-Dko-1.mm10.CG.meth,$MethCall/WGBS-DKO-2.mm10.CG.meth \
 -label DFL1,DFL2,DKO1,DKO2 \
 -o $TEMP/MasterTable_CT
sort -k1,1 -k2,2n $TEMP/MasterTable_CT_C.txt > $TEMP/tem; mv $TEMP/tem $MT/MasterTable_CT.txt
mv $TEMP/MasterTable_CT.HeaderInfo $MT/MasterTable_CT.HeaderInfo
