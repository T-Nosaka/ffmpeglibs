#!/bin/bash

SRCFOLDER=`pwd`

rm -rf output/*

rm -rf ~/fdk-aac
cp -rp ../fdk-aac ~/.

cd ~/fdk-aac
./scratch.sh

mkdir -p ${SRCFOLDER}/output
cp -rp output/* ${SRCFOLDER}/output/
