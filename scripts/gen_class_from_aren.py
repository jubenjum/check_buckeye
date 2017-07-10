#!/usr/bin/env python

import os
import sys
from collections import defaultdict
from itertools import count


# decoding the output from Aren's ZRTools 
try:
    f_disc_pairs = sys.argv[1]   
except:
    print('use gen_class;py [out.1] ')
    sys.exit()

dpairs = defaultdict(list)
with open(f_disc_pairs) as fdisc:
    for line in fdisc.readlines():
        l = line.strip().split(' ')

        # file1 file2
        if len(l) == 2: # the names of files
            pair_files = ' '.join(l)

        # desctiption of columns in 
        # https://github.com/arenjansen/ZRTools/blob/master/plebdisc/rescore_singlepair_dtw.c#L321
        # col1 = starting frame of file 1 (1frame = 1/100s)
        # col2 = ending frame fo file 1
        # col2 = starting frame of file 2 
        # col4 = ending frame fo file 2
        # col5 = new dtw  
        # col6 = rho (???)
        # col7 = old dtw
        elif len(l) == 7: # the resulting pairs 
            dpairs[pair_files].append([float(x) for x in l])
        else:
            print(l)
            sys.exit()

# the list of dwt to test from the command:
# $ awk '{if($5>=dtw) {printf("%5.2f\n", $5 )}}' dtw=0.0 \
#     exp/buckeye_S0064_P0008_B0100_D0010/matches/out.1  | sort | uniq > list_dwt.txt        
dtws = [float(x.strip()) for x in open('list_dwt.txt').readlines() ]

# crate a file for each dwt in out_dwt
for dtw in dtws:
    print('doing {}'.format(dtw))
    with open('out_dwt/DWT{:03d}.class'.format(int(dtw*100.0)), 'w') as f:
        n = count()
        for file_pair in dpairs.keys():
            fileX, fileY = file_pair.split(' ')
            for res in dpairs[file_pair]:
                if res[4] >= dtw: # save in the class file
                    t_ = 'Class {}\n'.format(n.next())
                    t_+= '{} {:5.4f} {:5.4f}\n'.format(fileX, res[0]/100.0, res[1]/100.0)
                    t_+= '{} {:5.4f} {:5.4f}\n'.format(fileY, res[2]/100.0, res[3]/100.0)
                    t_+= '\n'
                    f.write(t_)
