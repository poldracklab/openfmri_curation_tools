# OpenfMRI Data Curation Tools

As they develop and mature, tools for curating datasets for OpenfMRI will be
tracked here.

## openfmri_download_dataset

Download an entire OpenfMRI dataset with a single command. Optionally download the entire OpenfMRI inventory.

```
usage: openfmri_download_dataset [-h] [--all] [--dataset DATASET]

optional arguments:
  -h, --help         show this help message and exit
  --all              Download all data for all datasets (lengthy process).
  --dataset DATASET  The dataset accession number to download
```

## create_subject_tar_package

Package up a BIDS formatted dataset's subject folders into evenly sized (based on _uncompressed_ size) archives. The max size is per archive is about 4 GB.

Running this script prints the tar commands to standard output, mainly for use in an
HPC environment, but the commands can also be piped to a shell to execute them sequentially.

```
usage: create_subject_tar_package.sh /path/to/BIDS_dataset [ | bash ]
```
