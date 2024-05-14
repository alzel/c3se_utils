#!/bin/bash

# Define some variables from C3SE_quota

files_used=`echo $(((((C3SE_quota | grep 'Files used')|cut -d \t -f 1,2)|grep -Eo '[0-9]{1,15}')|sort -n)|tail -n 1)`
files_quota=`echo $(((((C3SE_quota | grep 'Files used')|cut -d \t -f 2,3)|grep -Eo '[0-9]{1,15}')|sort -n)|tail -n 1)`
space_used=`echo $(((((C3SE_quota | grep 'Space used')|cut -d \t -f 1,2)|grep -Eo '[0-9]{1,15}')|sort -n)|tail -n 1)`
space_quota=`echo $(((((C3SE_quota | grep 'Space used')|cut -d \t -f 2,3)|grep -Eo '[0-9]{1,15}')|sort -n)|tail -n 1)`
space_usedB=$(awk -v num=$space_used 'BEGIN{print num*1073741824}')

# Print overall file and space usage

printf "\nFiles Used: %-10d\nFiles Quota: %-10d\nPercent Used Files: " $files_used $files_quota
(calc(){ awk "BEGIN { print "$*" }"; };calc 100*$files_used/$files_quota)

printf "\nSpace Used (GB): %-10d\nSpace Quota (GB): %-10d\nPercent Used Space: " $space_used $space_quota
(calc(){ awk "BEGIN { print "$*" }"; };calc 100*$space_used/$space_quota)

# Draw table

echo "
=============================================================================================
|        FOLDER NAME        |   # FILES    |   SPACE USED   | % TOTAL FILES | % TOTAL SPACE |
---------------------------------------------------------------------------------------------"

# Run loop through folders, populate table. If loop used to convert from Kb,Mb,Gb,Tb to bytes for percentage calculation

for dirname in */; do
  fileNo=`echo $(lfs find $(pwd)/${dirname} 2>/dev/null | wc -l)`;
  spaceNo=`echo $(du -hs ${dirname} 2>/dev/null|cut -f1)`;
  suff=`echo -n $spaceNo| tail -c 1`
  if [ $suff == "K" ]; then
     spaceNoB=$(awk -v num=$(echo $spaceNo|sed s'/.$//') 'BEGIN{print num*1024}')
  elif [ $suff == "M" ]; then
     spaceNoB=$(awk -v num=$(echo $spaceNo|sed s'/.$//') 'BEGIN{print num*1048576}')
  elif [ $suff == "G" ]; then
     spaceNoB=$(awk -v num=$(echo $spaceNo|sed s'/.$//') 'BEGIN{print num*1073741824}')
  elif [ $suff == "T" ]; then
     spaceNoB=$(awk -v num=$(echo $spaceNo|sed s'/.$//') 'BEGIN{print num*1099511627776}')
  else 
     echo "No suffix found"
  fi
  printf "| %-25s |    %-9d |     %-10s |  %-12s |  %-12s |\n" ${dirname} $fileNo $spaceNo $(calc(){ awk "BEGIN { print "$*" }"; };calc 100*$fileNo/$files_used) $(calc(){ awk "BEGIN { print "$*" }"; };calc 100*$spaceNoB/$space_usedB);
done

# Close table

echo "============================================================================================="