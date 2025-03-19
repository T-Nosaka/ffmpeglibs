#!/bin/bash

rm -rf output/*

cd x264-snapshot-20191217-2245-stable

#TOOLCHAIN
export NDKVER=28.0.13004108
export CMAKEVER=3.31.5

PLATFORMNAME=`uname -s`
if [ $PLATFORMNAME = "Darwin" ]; then
export ANDROID_SDK=~/Library/Android/Sdk
LLVMPLATFORM="darwin-x86_64"
else
export ANDROID_SDK=~/Android/Sdk
LLVMPLATFORM="linux-x86_64"
fi
export NDK=${ANDROID_SDK}/ndk/${NDKVER}
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/${LLVMPLATFORM}
export ANDROID_NDK_ROOT=${NDK}
export MAKE=${NDK}/prebuilt/${LLVMPLATFORM}/bin/make

#API
export API=26

#OUTPUT
export OUTPUT_DIR=`pwd`/../output

make_android() {

  export TARGET=$1
  export ARCH=$2
  export NDKARCH=$3
  export CFLAGS=$4
  export LDFLAGS=$5

  #Configure and build.
  export AR=$TOOLCHAIN/bin/llvm-ar
  export LD=$TOOLCHAIN/bin/ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
  export CC=$TOOLCHAIN/bin/$TARGET$API-clang
  export AS=$CC
  export NM=$TOOLCHAIN/bin/llvm-nm
  export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
  export PATH=$TOOLCHAIN/bin:${PATH}
  ./configure \
    --enable-static \
    --disable-opencl \
    --disable-win32thread \
    --disable-asm

  ${MAKE}
  mkdir -p ${OUTPUT_DIR}/${NDKARCH}

  find . -name '*.a' -print | xargs -I % -t cp % ${OUTPUT_DIR}/${NDKARCH}/.
  find . -name '*.h' | cpio -pdmu ${OUTPUT_DIR}/${NDKARCH}

  ${MAKE} clean
}

#ABI armv7a
#make_android armv7a-linux-androideabi ARM armeabi-v7a "" ""

#ABI aarch64
make_android aarch64-linux-android AARCH64 arm64-v8a "-fPIC" ""

#ABI x86
#make_android i686-linux-android X86 x86 "" ""

#ABI x86_64
make_android x86_64-linux-android X86_64 x86_64 "-fPIC" ""