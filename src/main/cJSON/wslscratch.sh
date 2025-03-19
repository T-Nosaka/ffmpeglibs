#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/cJSON
cp -rp ../cJSON ~/.

cd ~/cJSON
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
