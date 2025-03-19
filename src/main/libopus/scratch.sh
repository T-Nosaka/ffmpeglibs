#!/bin/bash

rm -rf output/*

cd opus-1.5.2

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
  export CROSSHOST=$4
  export CFLAGS=$5
  export LDFLAGS=$6

  #Configure and build.
   export AR=$TOOLCHAIN/bin/llvm-ar
   export LD=$TOOLCHAIN/bin/ld
   export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
   export STRIP=$TOOLCHAIN/bin/llvm-strip
   export CC=$TOOLCHAIN/bin/$TARGET$API-clang
   export AS=$CC
   export NM=$TOOLCHAIN/bin/llvm-nm
   export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
  ./configure \
    --target=$ARCH \
    --host=$CROSSHOST \
    --enable-static \
    --disable-doc

  ${MAKE}
  mkdir -p ${OUTPUT_DIR}/${NDKARCH}

  find . -name '*.a' -print | xargs -I % -t cp % ${OUTPUT_DIR}/${NDKARCH}/.
  cp -r include/* ${OUTPUT_DIR}/${NDKARCH}/.

  ${MAKE} clean
}

#ABI armv7a
make_android armv7a-linux-androideabi armv7-android-gcc armeabi-v7a armv7-linux-gnu "" ""

#ABI aarch64
make_android aarch64-linux-android arm64-android-gcc arm64-v8a aarch64-linux-gnu "" ""

#ABI x86
#make_android i686-linux-android x86-android-gcc x86 x86-linux-gnu "" ""

#ABI x86_64
make_android x86_64-linux-android x86_64-android-gcc x86_64 x86_64-linux-gnu "" ""
