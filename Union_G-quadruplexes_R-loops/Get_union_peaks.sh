### Get the union of the G-quadruplexes and R-loops

### With the union of G quadruplexes and union of R-loops, get all the peaks

/home/danielasc/software/bedtools2/bin/intersectBed -a /mnt/BioScratch/danielasc/20200610/Gquad/union_corrected_regions.bed -b /mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input/mergepeaks_intersect_dfl_dko_123_rm_bl.bed  -v|cut -f 1,2,3 |sort|uniq         > new_unique_g4s_from_g4_overlap.bed
/home/danielasc/software/bedtools2/bin/intersectBed -a /mnt/BioScratch/danielasc/20200610/Gquad/union_corrected_regions.bed -b /mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input/mergepeaks_intersect_dfl_dko_123_rm_bl.bed  -wa -wb|cut -f 14,15,16 |sort|uniq > new_overlap_g4s_rloops_rloops_peaks.bed
/home/danielasc/software/bedtools2/bin/intersectBed -b /mnt/BioScratch/danielasc/20200610/Gquad/union_corrected_regions.bed -a /mnt/BioScratch/danielasc/Redo_Rloops/macs2_chip_input/mergepeaks_intersect_dfl_dko_123_rm_bl.bed  -v|cut -f 1,2,3 |sort|uniq         > new_unique_rloops_from_g4_overlap.bed 

cat new_unique_g4s_from_g4_overlap.bed new_unique_rloops_from_g4_overlap.bed new_overlap_g4s_rloops_rloops_peaks.bed > new_union_g4_rloops_overlap.bed

