#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/ffmpeg
cp -rp ../ffmpeg ~/.

cd ~/ffmpeg
./scratch.sh ${SRCFOLDER}

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
