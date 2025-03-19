#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/libopus
cp -rp ../libopus ~/.

cd ~/libopus
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
