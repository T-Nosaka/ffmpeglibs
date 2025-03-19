#!/bin/bash

rm -rf output/*

cd vvenc-1.13.0

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
export CMAKE=${ANDROID_SDK}/cmake/${CMAKEVER}/bin/cmake
export ANDROID_NDK_ROOT=${NDK}
export MAKE=${NDK}/prebuilt/${LLVMPLATFORM}/bin/make
export PATH=$TOOLCHAIN/bin:${PATH}

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

  ${CMAKE}  \
  -Bmakegenerate/${NDKARCH} \
  -DENABLE_SHARED=OFF \
  -DENABLE_CLI=OFF \
  -DSTATIC_LINK_CRT=ON \
  -DLINT=OFF \
  -DANDROID_ABI=${NDKARCH} \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_NDK=${NDK} \
  -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
  -DCMAKE_VERBOSE_MAKEFILE=TRUE \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MAKE_PROGRAM=${MAKE}

  cd makegenerate/${NDKARCH}
  ${MAKE}
  mkdir -p ${OUTPUT_DIR}/${NDKARCH}

  cp -rp vvenc ${OUTPUT_DIR}/${NDKARCH}/.
  cd ../..
  find . -name '*.a' -print | xargs -I % -t cp % ${OUTPUT_DIR}/${NDKARCH}/.
  cp -rp include ${OUTPUT_DIR}/${NDKARCH}/.

  cd makegenerate/${NDKARCH}
  ${MAKE} clean

  cd ../..
}

#ABI armv7a
#make_android armv7a-linux-androideabi arm armeabi-v7a "" ""

#ABI aarch64
make_android aarch64-linux-android aarch64 arm64-v8a "" ""

#ABI x86
#make_android i686-linux-android x86_32 x86 "" ""

#ABI x86_64
make_android x86_64-linux-android x86_64 x86_64 "" ""
