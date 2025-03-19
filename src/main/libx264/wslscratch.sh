#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/libx264
cp -rp ../libx264 ~/.

cd ~/libx264
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
