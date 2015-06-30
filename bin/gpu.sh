#!/bin/csh
# !/bin/bash
#oarsub -I -l nodes=1/core=16,walltime=12 -p "gpu='YES'"
oarsub -I -l nodes=1/cpu=1,walltime=12 -p "gpu='YES'"
exit
#oarsub -I -l nodes=1/core=8 -p "mem_total_mb>=64000"
#oarsub -I -l nodes=1/core=8,walltime=72000 -p "mem_total_mb>=64000"
#oarsub -I -l nodes=1/core=1,walltime=72000 -p "mem_total_mb>=64000"
#oarsub -I -l nodes=1/core=16,walltime=72
set numCores=4
if ($1 == '') then
	echo " Hint: usage is: " $0 " [number of cores]"
	#echo 'e.g.: ' $0 '.'
	#exit
else
	set numCores=$1
endif
echo " (...now asking for $numCores cores)"
oarsub -I -l nodes=1/core=$numCores,walltime=72

