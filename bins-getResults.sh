#!/usr/bin/env sh
cd /home/feste/opt/aws-mturk-clt-1.3.1/bin
./getResults.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 -successfile /home/feste/CoCoLab/prior-elicitation-bins/bins.success -outputfile /home/feste/CoCoLab/prior-elicitation-bins/bins.results
cd /home/feste/CoCoLab/prior-elicitation-bins