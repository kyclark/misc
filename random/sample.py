#!/usr/bin/env python

from Bio import SeqIO
import argparse
import random
import os

def get_args():
    parser = argparse.ArgumentParser(description='Process output from Mash')
    parser.add_argument('-f', '--fasta', metavar='FILE',
            type=str, help='FASTA file', required=True)
    parser.add_argument('-o', '--out_dir', metavar='DIR',
            type=str, help='Output directory', default="")
    parser.add_argument('-p', '--pct', metavar='PERCENT', 
            type=float, default=.2)
    parser.add_argument('-n', '--num', metavar='NUMBER', type=int, default=0)
    return parser.parse_args()

def main():
    args    = get_args()
    fasta   = args.fasta
    pct     = args.pct
    num     = args.num
    out_dir = args.out_dir

    #
    # Check input from user
    #
    if not os.path.isfile(fasta):
        print("{} is not a file".format(fasta))
        exit(1)

    if len(out_dir) == 0:
        out_dir, base = os.path.split(fasta)

    if not os.path.isdir(out_dir):
        os.mkdir(out_dir)
        exit(1)

    #
    # Count how many records are in the FASTA file
    #
    count = 0
    for record in SeqIO.parse(fasta, "fasta"):
        count += 1

    #
    # Either take a static number of records or a percentage
    #
    if (num == 0) and (not 0 < pct < 1):
        print("--pct ({}) must be b/w 0 and 1".format(pct))
        exit(1)

    num_take = num if num > 0 else round(count * pct)
    if num_take > count:
        print("Can't take '{}' from '{}' sequences".format(num_take, count))
        exit(1)

    #
    # Take a random sample and sort the output
    #
    n = sorted(random.sample(range(count), num_take))

    #
    # E.g., input "/foo/test.fa" output "/foo/test.sub.fa"
    #
    base, ext = os.path.splitext(os.path.basename(fasta))
    out_file  = os.path.join(out_dir, base + '.sub' + ext)

    #
    # When the record number equals the next number in the sample,
    # print it to the output file.
    #
    with open(out_file, 'wt') as fh:
        take = n.pop(0)
        for pos, record in enumerate(SeqIO.parse(fasta, "fasta")):
            if pos == take:
                SeqIO.write(record, fh, "fasta")
                if len(n) > 0:
                    take = n.pop(0)
                else:
                    break

    print('Done, put {} sequence{} into "{}"'.format(
        num_take, '' if num_take == 1 else 's', out_file))

if __name__ == '__main__':
    main()
