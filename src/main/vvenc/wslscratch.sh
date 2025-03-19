#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/vvenc
cp -rp ../vvenc ~/.

cd ~/vvenc
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
