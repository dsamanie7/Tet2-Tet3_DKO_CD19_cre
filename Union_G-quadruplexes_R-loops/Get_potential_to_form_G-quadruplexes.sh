
### Get shuffled regions

cd /mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input

/home/danielasc/software/bedtools2/bin/shuffleBed -i new_union_g4_rloops_overlap.bed -excl new_union_g4_rloops_overlap.bed -seed 12345 -g /mnt/BioAdHoc/Groups/RaoLab/Bioinformatics/apps/Mus_musculus/UCSC/mm10/chromosomes/mm10.chrom.sizes |cut -f1,2,3 > shuffle_new_union_g4_rloops_overlap.bed

### In the folder "/mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input/pG4" there will be two bed files:  the G4/Rloops peaks "new_union_g4_rloops_overlap.bed", and the shuffled regions file "shuffle_new_union_g4_rloops_overlap.bed"


### Use regular expression to get Potential to form G quadruplexes 

    dana=/mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input/pG4
  refgen=/mnt/BioAdHoc/Groups/RaoLab/Bioinformatics/apps/Mus_musculus/UCSC/mm10/BowtieIndex/genome.fa
  Btools=/home/danielasc/software/bedtools2/bin/bedtools
 AnnPeak=/home/danielasc/software/HOMER/bin/annotatePeaks.pl

# >>>>>> (1) Fasta sequences:

# >>> Get a general summary
for i in `ls $dana/*.bed`; do 
  echo $i >> $dana/FilesSummary.txt
   /home/danielasc/software/BEDStats  -b $i >> $dana/FilesSummary.txt
  echo >> $dana/FilesSummary.txt
done

# >>> Bedtools get fasta:
for i in `ls $dana/*bed`; do
  $Btools getfasta -fi $refgen -bed $i -name > ${i/.bed/.fa};
done

# >>>>>> (2) Pattern Maatching (this time in awk)
# >>> G3 N(1-7) G3  N(1-7) G3   N(1-7) G3
# >>> G2 N(1-7) G2  N(1-7) G2  N(1-7) G2
for i in `ls ${dana}/*fa`; do
  awk '{if($_ ~/^>/){match($_, "::(chr.*):([0-9]*)-([0-9]*)", ary);next}
         if(toupper($_) ~/([G]{3}\w{1,7}){3}[G]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t+\tLoop1-7_G\t"toupper($_)}
	#else if(toupper($_) ~/GG[ATCG]{1,7}GG[ATCG]{1,7}GG[ATCG]{1,7}GG/)       {print ary[1]"\t"ary[2]"\t"ary[3]"\t+\tGG\t"toupper($_)}
	else if(toupper($_) ~/([C]{3}\w{1,7}){3}[C]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tLoop1-7_C\t"toupper($_)}
	else if(toupper($_) ~/[G]{3}\w{1,12}[G]{3}\w{1,21}[G]{3}\w{1,12}[G]{3}/) {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tLong-Loop_G\t"toupper($_)}
	else if(toupper($_) ~/[C]{3}\w{1,12}[C]{3}\w{1,21}[C]{3}\w{1,12}[C]{3}/) {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tLong-Loop_C\t"toupper($_)}
	else if(toupper($_) ~/([G]{2}\w{1,7}[G]{1}|[G]{1}\w{1,7}[G]{2})\w{1,7}([G]{3}\w{1,7}){2}[G]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_G\t"toupper($_)}
	else if(toupper($_) ~/[G]{3}\w{1,7}([G]{2}\w{1,7}[G]{1}|[G]{1}\w{1,7}[G]{2})\w{1,7}[G]{3}\w{1,7}[G]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_G\t"toupper($_)}
	else if(toupper($_) ~/[G]{3}\w{1,7}[G]{3}\w{1,7}([G]{2}\w{1,7}[G]{1}|[G]{1}\w{1,7}[G]{2})\w{1,7}[G]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_G\t"toupper($_)}
	else if(toupper($_) ~/[G]{3}\w{1,7}([G]{3}\w{1,7}){2}([G]{2}\w{1,7}[G]{1}|[G]{1}\w{1,7}[G]{2})/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_G\t"toupper($_)}
	else if(toupper($_) ~/([C]{2}\w{1,7}[C]{1}|[C]{1}\w{1,7}[C]{2})\w{1,7}([C]{3}\w{1,7}){2}[C]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_C\t"toupper($_)}
	else if(toupper($_) ~/[C]{3}\w{1,7}([C]{2}\w{1,7}[C]{1}|[C]{1}\w{1,7}[C]{2})\w{1,7}[C]{3}\w{1,7}[C]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_C\t"toupper($_)}
	else if(toupper($_) ~/[C]{3}\w{1,7}[C]{3}\w{1,7}([C]{2}\w{1,7}[C]{1}|[C]{1}\w{1,7}[C]{2})\w{1,7}[C]{3}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_C\t"toupper($_)}
	else if(toupper($_) ~/[C]{3}\w{1,7}([C]{3}\w{1,7}){2}([C]{2}\w{1,7}[C]{1}|[C]{1}\w{1,7}[C]{2})/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tSimple-bulge_C\t"toupper($_)}
	else if(toupper($_) ~/([G]{2}\w{1,5}){3}[G]{2}/)   {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tTwoTetrad-CB_G\t"toupper($_)}
	else if(toupper($_) ~/([C]{2}\w{1,5}){3}[C]{2}/)  {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tTwoTetrad-CB_C\t"toupper($_)}
	#else if(toupper($_) ~/CC[ATCG]{1,7}CC[ATCG]{1,7}CC[ATCG]{1,7}CC/)       {print ary[1]"\t"ary[2]"\t"ary[3]"\t-\tCC\t"toupper($_)}
	else {print ary[1]"\t"ary[2]"\t"ary[3]"\t.\tOther\t"toupper($_)}
  }' $i > ${i/.fa/.bed.Gquads}
done

Gquads=(`basename -a $(ls *.Gquads)`)
names=(`basename -a $(ls *.Gquads) | cut -f1 -d\.`)
echo '# >>>>>> Gquad-forming sequences ' >>  $dana/FilesSummary.txt
for i in $(seq 0 `echo ${#Gquads[@]}-1 | bc`); do 
  printf ${names[$i]}"\t"  >>  $dana/FilesSummary.txt
  grep -v "\Other" ${Gquads[$i]} | wc -l >>  $dana/FilesSummary.txt
done
echo  >>  $dana/FilesSummary.txt

cut -f5 new_union_g4_rloops_overlap.bed.Gquads |sort| uniq -c
cut -f5 shuffle_new_union_g4_rloops_overlap.bed.Gquads |sort| uniq -c

