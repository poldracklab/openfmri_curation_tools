#!/bin/bash

## Note: requires nifti_tool to be present in your path to run.
## nitfi_tool is available from various sources:
##  http://nifti.nimh.nih.gov/pub/dist/src/utils/nifti_tool.c
##  http://nifticlib.sourcearchive.com/documentation/1.1.0/dir_009f2fac150e1b8d6e6d7acbc4e86559.html
##  ...
## Typical usage of this script:
## $ find dataset_dir -type f \( -name "*.nii" -or -name "*.nii.gz" \) -exec nifti_hdr_parse.sh {} \; > data_file.tsv
## to produce a tab-separated file containing the header fields
## for all nifti files (including dirname/basename).

IFS=$'\n'

file=${1}

if [ -z ${file} ]; then
        echo "No file provided. Usage `basename $0` [file to index]." >&2
        exit 1
elif [ ! -e ${file} ]; then
        echo "Apparently, the file ${file} does not exist." >&2
        exit 1
fi

filebase=$(basename ${file})
filedir=$(dirname ${file})

while read line; do

        echo -e "${filedir}\t${filebase}\t${line}"

done < <(nifti_tool -disp_hdr -infiles ${file} | \
        awk ' NR > 6 { print } ' | \
        perl -p -e "s/^\s*([a-zA-Z0-9_]+)\s*(\d+)\s*(\d+)\s*(.+)$/\1\t\2\t\3\t\4/g")
