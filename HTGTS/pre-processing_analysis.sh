### Use HTGTS pipeline (https://github.com/robinmeyers/transloc_pipeline)

#!/bin/bash -x
#PBS -N HTGTS-DFL-1
#PBS -l walltime=47:00:00
#PBS -o /mnt/BioScratch/danielasc/HTGTS/debugged2/Jobs/HTGTS-DFL-1.out
#PBS -e /mnt/BioScratch/danielasc/HTGTS/debugged2/Jobs/HTGTS-DFL-1.out
#PBS -j oe
#PBS -l nodes=1:ppn=8
#PBS -M danielasc@lji.org
#PBS -l mem=90GB
#PBS -m ae
#PBS -q default

source /mnt/BioApps/htgts/setup.sh
TEMP=/mnt/BioScratch/danielasc

# >2. Generate Sample-speficif metadata:
Samples=(HTGTS-DFL-1 HTGTS-DFL-2 HTGTS-DKO-1 HTGTS-DKO-2 )

# >4. Indicate sample and run the Wrapper:
### HTGTS-DFL-1 ==0,  HTGTS-DFL-2 ==1,  HTGTS-DKO-1 ==2, HTGTS-DKO-2 ==3

Sample=${Samples[0]}
TranslocWrapper.pl    /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/metadata.txt /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/preprocess /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/results --threads 8

# >5. Run Hand-corrected R scripts
$TEMP/TrDdp.R /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/results/$Sample/${Sample}.tlx   /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/results/$Sample/${Sample}_duplicate.txt --offset.dist 0 --barcode 0 --break.dist 0 --cores 8

# >6. Run filter_junctions
/mnt/BioApps/htgts/transloc_pipeline/bin/TranslocFilter.pl  \
  /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/results/$Sample/${Sample}.tlx        \
  /mnt/BioScratch/danielasc/HTGTS/debugged2/$Sample/results/$Sample/${Sample}_result.tlx \
  --filters "f.unaligned=1 f.baitonly=1 f.uncut=G10 f.misprimed=L10 f.freqcut=1 f.largegap=G30 f.mapqual=1 f.breaksite=1 f.sequential=1 f.repeatseq=1 f.duplicate=1"

# >7. Run Wrapper skipping initial process to do sort_junctions && post_process_junctions only:
/mnt/BioApps/htgts/transloc_pipeline/bin/../R/TranslocPlot.R /mnt/BioScratch/danielasc/HTGTS/debugged2/${Sample}/results/${Sample}/${Sample}_result.tlx /mnt/BioScratch/danielasc/HTGTS/debugged2/${Sample}/results/${Sample}/${Sample}.pdf         binsize=2000000 strand=2 assembly=mm10 brkchr=chr12 brksite=113425701 brkstrand=-1
/mnt/BioApps/htgts/transloc_pipeline/bin/../R/TranslocPlot.R /mnt/BioScratch/danielasc/HTGTS/debugged2/${Sample}/results/${Sample}/${Sample}_result.tlx /mnt/BioScratch/danielasc/HTGTS/debugged2/${Sample}/results/${Sample}/${Sample}_brksite.pdf strand=0 assembly=mm10 brkchr=chr12 brksite=113425701 brkstrand=-1 chr=chr12 rmid=113425701 rwindow=50000 binnum=100 plottype=linear


