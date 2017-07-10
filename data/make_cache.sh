#!/bin/bash 

set -e

# load config

. ../config


S=$1
DIM=39
N_JOBS=1

VAD_DIR=${PWD}/vad
CACHE=${PWD}/cache
LOC_TMP=$PWD

# output dirs
mkdir -p ${CACHE}/D${DIM}S${S}/feat
mkdir -p ${CACHE}/D${DIM}S${S}/lsh
mkdir -p ${CACHE}/D${DIM}S${S}/wav


tempdir=$(mktemp -d --tmpdir=${LOC_TMP});
echo "### " $tempdir     

# the random proj file 
genproj -D $DIM -S $S -seed 1 -projfile ${CACHE}/proj_S${S}xD${DIM}_seed1

# from generate_plp_lsh
function p_norm() {
    file_=$1;
    id=$(basename $file_ .wav);
   
    out_wav=${tempdir}/${id}.wav
    #out_wav=${CACHE}/D${DIM}S${S}/wav/${id}.wav
    # Get audio into a 16-bit 8kHz wav file
    echo ">>>>>> doing sox";
    sox -v 0.8 -t wav $file_ -t wav -e signed-integer \
        -b 16 -c 1 -r 8000 $out_wav  

    ### Generate 39-d PLP (13 cc's + delta + d-deltas using ICSI feacalc)
    echo ">>>>>> doing feacalc"; 
    feacalc -plp 12 -cep 13 -dom cep  -deltaorder 2 \
       -dither -frqaxis bark -samplerate 8000 -win 25 \
       -step 10 -ip MSWAVE -rasta false -compress true \
       -op swappedraw -o ${tempdir}/${id}.binary \
       ${tempdir}/${id}.wav
    
    echo ">>>>>> doing standfeat";
    standfeat -D $DIM -infile ${tempdir}/${id}.binary \
        -outfile ${tempdir}/${id}.std.binary \
        -vadfile ${VAD_DIR}/${id}

    echo ">>>>>> doing lsh";
    lsh -D $DIM -S $S -projfile ${CACHE}/proj_S${S}xD${DIM}_seed1 \
        -featfile ${tempdir}/${id}.std.binary \
        -sigfile ${tempdir}/${id}.std.lsh64 -vadfile ${VAD_DIR}/${id}

    cp -rf ${tempdir}/${id}.std.lsh64 ${CACHE}/D${DIM}S${S}/lsh
    cp -rf ${tempdir}/${id}.std.binary ${CACHE}/D${DIM}S${S}/feat

}


for i in $(cat ${CORPUS}.lst); do p_norm $i; done
rm -rf $tempdir

exit 1;

