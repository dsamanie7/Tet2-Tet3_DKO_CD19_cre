

# >>>>>> Tracks for coverage and methylation levels
for i in WGBS-DKO-2.mm10.CG.meth WGBS-Dfl-2.mm10.CG.meth WGBS-Dko-1.mm10.CG.meth WGBS-dfl-1.mm10.CG.meth; do
 awk '{if(NR==1){next} printf "%s\t%i\t%i\t%.0f\n",  $1,$2,$3,$4*100/$5}' $MethCall/$i | grep -v chrPhagueLambda > $BW/${i}.bg           &
 awk '{if(NR==1){next} printf "%s\t%i\t%i\t%i\n",  $1,$2,$3,$5}'          $MethCall/$i | grep -v chrPhagueLambda > $BW/${i/.meth}.cov.bg &
done

for i in WGBS-DKO-2.mm10.CG.meth WGBS-Dfl-2.mm10.CG.meth WGBS-Dko-1.mm10.CG.meth WGBS-dfl-1.mm10.CG.meth; do
 $bg2bw $BW/${i}.bg           $BW/${i}.bw           mm10 &
 $bg2bw $BW/${i/.meth}.cov.bg $BW/${i/.meth}.cov.bw mm10 &
done

track type=bigWig name=WGBS-DKO-1  description="Methylation"   visibility=2 autoScale=off maxHeightPixels=30 viewLimits=0:100 color=255,0,0     graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-Dko-1.mm10.CG.meth.bw
track type=bigWig name=WGBS-DKO-2  description="Methylation"   visibility=2 autoScale=off maxHeightPixels=30 viewLimits=0:100 color=255,0,0     graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-DKO-2.mm10.CG.meth.bw
track type=bigWig name=WGBS-Dfl-1  description="Methylation"   visibility=2 autoScale=off maxHeightPixels=30 viewLimits=0:100 color=0,0,255     graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-dfl-1.mm10.CG.meth.bw
track type=bigWig name=WGBS-Dfl-2  description="Methylation"   visibility=2 autoScale=off maxHeightPixels=30 viewLimits=0:100 color=0,0,255     graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-Dfl-2.mm10.CG.meth.bw
                                                                                                          
track type=bigWig name=WGBS-DKO-1.cov  description="Coverage"  visibility=2 autoScale=off  maxHeightPixels=30 viewLimits=0:20 color=128,128,128   graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-Dko-1.mm10.CG.cov.bw
track type=bigWig name=WGBS-DKO-2.cov  description="Coverage"  visibility=2 autoScale=off  maxHeightPixels=30 viewLimits=0:20 color=128,128,128   graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-DKO-2.mm10.CG.cov.bw
track type=bigWig name=WGBS-Dfl-1.cov  description="Coverage"  visibility=2 autoScale=off  maxHeightPixels=30 viewLimits=0:20 color=128,128,128   graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-dfl-1.mm10.CG.cov.bw
track type=bigWig name=WGBS-Dfl-2.cov  description="Coverage"  visibility=2 autoScale=off  maxHeightPixels=30 viewLimits=0:20 color=128,128,128   graphType=bar    bigDataUrl=https://informaticsdata.liai.org/NGS_analyses/ad_hoc/Groups/RaoLab/Edahi/11.NGS_Trials/DanielaSamaniego/20200622/06.BigWigs/WGBS-Dfl-2.mm10.CG.cov.bw

# >>>>>> Tracks for DMRs: positive difference means more methylated in DKO.
echo 'track name="DMRs"  description="Red:DKO+ --- Blue:DFL+" visibility=1 itemRgb="On"' > $BW/DMRs.DKO_vs_DFL.bed
awk -v OFS="\t" '$6 < 0 {print $1,$2,$3,"Peak_"NR,0,"+",$2,$3,"0,0,255"} $6>0 {print $1,$2,$3,"Peak_"NR,0,"+",$2,$3,"255,0,0"}' $RadMeth/DMRs.DFL_vs_DKO_0.05_Pval_with3CpGs.txt  >> $BW/DMRs.DKO_vs_DFL.bed

