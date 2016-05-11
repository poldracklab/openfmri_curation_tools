#!/usr/bin/env python
#
# Purpose: To simplify the downloading of an openfMRI dataset by using
# the OpenfMRI API and downloading all of the dataset links.
#

import requests
import sys, os
import argparse as argp
from urlparse import urlparse

def openfmri_download_dataset ():

    url = "https://openfmri.org/dataset/api/"

    # Request information to obtain file/folder list.
    headers = {
        "Content-Type": "application/json"
    }

    if (args['dataset'] is not None):
        url = url + args['dataset']

    r = requests.get(url, headers=headers)

    if (r.status_code >= 400):
        print("\nGot response code: %d (%s). Unable to continue...\n" \
            % (r.status_code, r.reason))
        sys.exit(1)

    datasets = r.json()

    if (args['dataset'] is not None):
        __fetch_from_json(datasets)
    else:
        for dataset in datasets:
            __fetch_from_json(dataset)


def __fetch_from_json (dataset):

    chunk_size= 1024*5*1000
    links = dataset['link_set']

    linknum = 0
    num_links = len(links)

    for link in links:

        linknum = linknum + 1
        urlparts = urlparse(link['url'])
        output_path = dataset['accession_number']+urlparts.path

        print("%s - [ %d of %d ] %s => %s" % \
                (dataset['accession_number'], linknum, num_links,
                link['url'], output_path))
        r_dl = requests.get(link['url'], stream=True)
        total_bytes = int(r_dl.headers['content-length'])

        if (os.path.isfile(output_path)):
        	local_size = os.path.getsize(output_path)
        	if (local_size == total_bytes):
        		print("Skipping file: %s (exists with same size as remote)." % output_path)
        		continue

        chunk_num = 0
        bytes_read = 0

        try:
            os.makedirs(os.path.dirname(output_path))
        except OSError as err:
            if (err.errno == 17):
                pass # OK if it already exists.
            else:
                print ("Error: %s (%d)" % (err.strerror, err.errno))
                raise
        except:
            raise

        with open(output_path, 'wb') as fd:
        	for chunk in r_dl.iter_content(chunk_size=chunk_size, decode_unicode=False):
        		chunk_num = chunk_num + 1
        		bytes_read = bytes_read + len(chunk)
        		fd.write(chunk)
        		print "[ %s: link %d of %d ] Read %d of %d bytes @ %0.1f %% complete." % \
                    (dataset['accession_number'], linknum, num_links, bytes_read,
                    total_bytes, (100.0*bytes_read)/total_bytes)

if (__name__ == "__main__"):

    parser = argp.ArgumentParser("openfmri_download_dataset")
    parser.add_argument('--all', help = "Download all data for all datasets (lengthy process).", required=False, action='store_true')
    parser.add_argument('--dataset', help = "The dataset accession number to download", type=str, required=False)

    args = vars(parser.parse_args())

    if (args['all'] is True and args['dataset'] is not None):
        print ("Arguments --all and --dataset are mutuall exclusive.")
        sys.exit(1)

    openfmri_download_dataset()

    #print(args)



