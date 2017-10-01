##### Require #####
# Inspect the current directory(“.”) and all sub-directory.
# Calculate the number of directories.
# Do not include ‘.’ and ‘..’
# Calculate the number of files.
# Calculate the sum of all file size.
# List the top 5 biggest files.
# Only consider the regular file. Do not count in the link, FIFO, block device... etc.

##### Limit #####
# Use one-line command to 
# No temporary file or shell variables.
# No “&&” “||” “>” “>>” “<” “;” “&”, but you can use them in the awk command. Actually, you don’t need them to finish this homework.
# Only pipes are allowed.

ls -lARS | awk '{if($5!=""){if($1 ~/^d/) {numOfDir++} else{numOfFile++} print $5, $9} total+=$5} END{print "Dir num:",numOfDir,"\nFile num:",numOfFile"\nTotal:",total}' | sort -nrk 1 | awk '{if(NR <= 5) {print NR":"$1"\t"$2} if($1 ~/^[A-Z]/){print $0}}'
