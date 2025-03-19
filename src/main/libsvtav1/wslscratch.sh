#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/libsvtav1
cp -rp ../libsvtav1 ~/.

cd ~/libsvtav1
./scratcharm.sh
./scratcharm64.sh
./scratchx64.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
