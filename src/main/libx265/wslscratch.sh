#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/libx265
cp -rp ../libx265 ~/.

cd ~/libx265
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
