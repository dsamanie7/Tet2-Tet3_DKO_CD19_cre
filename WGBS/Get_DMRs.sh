### Get DMRs

# >>> Generate input files for RadMeth
echo 'DFL1,DFL2,DKO1,DKO2' | tr ',' '\t' > $RadMeth/ProportionTable_CT_C.txt
awk -v OFS='\t' '{print $1":"$2":"$3":CG",$5,$4,$7,$6,$9,$8,$11,$10}' $MT/MasterTable_CT.txt >> $RadMeth/ProportionTable_CT_C.txt

printf '\tbase\tcase
DFL1\t1\t0
DFL2\t1\t0
DKO1\t1\t1
DKO2\t1\t1\n' > $RadMeth/DesignMatrix_tab.txt
# >>> Run RadMeth Regression --> Adjust --> Merge

cd $RadMeth
# Regression
$radmeth regression  -o $RadMeth/Regression.DFL_vs_DKO -v -f case $RadMeth/DesignMatrix_tab.txt $RadMeth/ProportionTable_CT_C.txt
# Adjust
$radmeth adjust      -bins 1:100:1  -o $RadMeth/Adjust.DFL_vs_DKO $RadMeth/Regression.DFL_vs_DKO
# Merge pval  0.01
$radmeth merge       -p 0.01 -o $RadMeth/DMRs.DFL_vs_DKO_0.01_Pval.txt $RadMeth/Adjust.DFL_vs_DKO
# Merge pval  0.05
$radmeth merge       -p 0.05 -o $RadMeth/DMRs.DFL_vs_DKO_0.05_Pval.txt $RadMeth/Adjust.DFL_vs_DKO

# >>> Filter DMRs with at least 3 CpGs:
awk '{if($5>2){print $_}}' $RadMeth/DMRs.DFL_vs_DKO_0.01_Pval.txt > $RadMeth/DMRs.DFL_vs_DKO_0.01_Pval_with3CpGs.txt
awk '{if($5>2){print $_}}' $RadMeth/DMRs.DFL_vs_DKO_0.05_Pval.txt > $RadMeth/DMRs.DFL_vs_DKO_0.05_Pval_with3CpGs.txt

