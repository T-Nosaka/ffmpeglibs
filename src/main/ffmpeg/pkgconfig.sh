#!/bin/bash
# set -x

#SRCFOLDER=""

pkg_name=${@: -1}

case $1 in
 --modversion)
   case $pkg_name in
     vulkan )
     echo "1.3.277"
     ;;
     *)
     ;;
   esac
 ;;
 --version)
   echo "0.29.2"
 ;;
 --cflags)
#   echo "cflags {$pkg_name}" >> ${SRCFOLDER}/pkgconfig.txt
   case $pkg_name in
     *)
     echo ""
     ;;
   esac
 ;;
 --exists)
#   echo "exist {$pkg_name}" >> ${SRCFOLDER}/pkgconfig.txt
   case $pkg_name in
     zlib | x264 | x265 | libvvenc | 1.6.1 | fdk-aac | opus | 1.4 | SvtAv1Enc | vulkan | 0.9.0 )
     ;;
     *)
     exit -1
     ;;
   esac
 ;;
 --variable=includedir)
 #  echo "includedir {$pkg_name}" >> ${SRCFOLDER}/pkgconfig.txt
   case $pkg_name in
     zlib | x264 | x265 | libvvenc | fdk-aac | opus | SvtAv1Enc | vulkan )
     echo "/usr/include"
     ;;
     *)
     echo "Package ${pkg_name} was not found in the pkg-config search path."
     echo "Perhaps you should add the directory containing \`${pkg_name}.pc'"
     echo "to the PKG_CONFIG_PATH environment variable"
     echo "No package '${pkg_name}' found"
     ;;
   esac
 ;;
 --libs)
 #  echo "libs {$pkg_name}" >> ${SRCFOLDER}/pkgconfig.txt
   case $pkg_name in
     zlib)
     echo "-lz"
     ;;
     x264)
     echo "-lx264"
     ;;
     x265)
     echo "-lx265"
     ;;
     libvvenc)
     echo "-lvvenc"
     ;;
     fdk-aac)
     echo "-lfdk-aac"
     ;;
     opus)
     echo "-lopus"
     ;;
     SvtAv1Enc)
     echo "-lSvtAv1Enc"
     ;;
     *)
     echo "Package ${pkg_name} was not found in the pkg-config search path."
     echo "Perhaps you should add the directory containing \`${pkg_name}.pc'"
     echo "to the PKG_CONFIG_PATH environment variable"
     echo "No package '${pkg_name}' found"
     ;;
   esac
 ;;
 *)
#  echo "arg {$1}" >> ${SRCFOLDER}/pkgconfig.txt
 ;;

esac

#echo ">> $1 $2 $3" >> ${SRCFOLDER}/pkgconfig.txt