#!/bin/bash

IFS=$'\n'

target=$1
if [ -z ${target} ] || [ ! -d ${target} ]; then
    (cat <<EOF

Usage: `basename $0` BIDS-folder-to-package

Package BIDS subject folders into a set of tarballs
having a maximum uncompressed size. Compression
efficiency may affect the final size of the archives.

Note: This tool only prints the resulting tar commands but
does not execute them.

EOF
) >&2
    exit 1
fi

maxSizePerArchive=3800000  # in kilobytes

# argument to tar (to be contructed)
subarg=

# cumulative total kbytes per package
totalKbytes=0

# where to save the pacakges
destdir=${target}/tarballs
destbase=${target}

function archiveit {
    mkdir -p ${destdir}
    # note symbolic link should be resolved and replaced by their target.
    # tested on MacOS X (bsdtar) and GNU tar.
    echo "tar -h -zcf ${destdir}/${destbase}_${firstsub}-${thissub}.tgz ${subarg}"
    totalKbytes=0
    subarg=
}

# note: assuming files found will not have spaces to shell
# metacharacters in them.
for sub in ${target}/sub-*; do

    thissub=$(echo `basename ${sub}` | sed -e "s/sub-//")

    if [ -z "${subarg}" ]; then
        firstsub=${thissub}
    fi

    subarg="'${sub}' ${subarg}"

    theseKbytes=$(du -sk ${sub} | awk ' { print $1 } ')
    totalKbytes=$((totalKbytes+${theseKbytes}))

    if [[ ${totalKbytes} -gt ${maxSizePerArchive} ]]; then
        archiveit
    fi

done

# get the leftovers...
if [[ ${totalKbytes} -gt 0 ]]; then
    archiveit
fi

