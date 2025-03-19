#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/libvpx
cp -rp ../libvpx ~/.

cd ~/libvpx
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
