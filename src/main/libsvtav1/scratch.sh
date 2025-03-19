#!/bin/bash

cd SVT-AV1-v2.3.0

rm -rf makegenerate

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
  export CMAKEFLAGS=$4
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

   export CMAKE_C_COMPILER=$CC
   export CMAKE_CXX_COMPILER=$CXX
   export CMAKE_ASM=$AS

  ${CMAKE}  \
  -Bmakegenerate/${NDKARCH} \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_TESTING=OFF \
  -DBUILD_APPS=OFF \
  -DANDROID_ABI=${NDKARCH} \
  -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
  -DANDROID_NDK=${NDK} \
  -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake \
  -DCMAKE_VERBOSE_MAKEFILE=TRUE \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=${CC} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DCMAKE_ASM=${AS} \
  -DCMAKE_MAKE_PROGRAM=${MAKE} \
  -DCMAKE_BUILD_TYPE="Release" \
  ${CMAKEFLAGS}


  cd makegenerate/${NDKARCH}
  ${MAKE}
  mkdir -p ${OUTPUT_DIR}/${NDKARCH}

  find ../../Bin/Release/ -name '*.a' -print | xargs -I % -t cp % ${OUTPUT_DIR}/${NDKARCH}/.
  cp -r ../../Source/API/* ${OUTPUT_DIR}/${NDKARCH}/.

  ${MAKE} clean
}

#ABI armv7a
#make_android armv7a-linux-androideabi armv7-android-gcc armeabi-v7a "" ""

#ABI aarch64
#make_android aarch64-linux-android arm64-android-gcc arm64-v8a "" ""

#ABI x86
#make_android i686-linux-android x86-android-gcc x86 "" ""

#ABI x86_64
#make_android x86_64-linux-android x86_64-android-gcc x86_64 "" ""
