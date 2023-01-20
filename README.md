Align two sets of sequences using minimap2 into a sorted BAM.

Minimap2 parameters can be changed. 
Defaults are tuned for ONT reads: `--eqx -x map-ont -n 10 -K 4g -k 17 -I 8g --secondary=no`

## Test locally

```sh
wget https://hgdownload.soe.ucsc.edu/goldenPath/ce11/bigZips/ce11.fa.gz
zcat ce11.fa.gz | head -10000 | gzip > target.fa.gz
wget https://hgdownload.soe.ucsc.edu/goldenPath/ce2/bigZips/ce2.fa.gz
zcat ce2.fa.gz | head -10000 | gzip > query.fa.gz

java -jar $CROMWELL_JAR run workflow.wdl -i inputs.json
```
