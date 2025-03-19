#!/bin/bash

#Project source folder
if [ "$#" -eq 1 ]; then
  export SRCFOLDER=$1
else
  export SRCFOLDER=`pwd`
fi

rm -rf output/*

cd FFmpeg-n7.1

#TOOLCHAIN
export NDKVER=28.0.13004108

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

  ${MAKE} distclean

  export TARGET=$1
  export ARCH=$2
  export NDKARCH=$3
  export CFLAGS=$4
  export LDFLAGS=$5

  #Library paths
  export C_INCLUDE_PATH=${SRCFOLDER}/../libx264/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../libx265/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../libvpx/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../libsvtav1/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../libsvtav1/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../fdk-aac/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../libopus/output/${NDKARCH}
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../vvenc/output/${NDKARCH}/include
  export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${SRCFOLDER}/../vvenc/output/${NDKARCH}

  #for configure test module
  export LDFLAGS=" -lstdc++"
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../libx265/output/${NDKARCH}
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../libx264/output/${NDKARCH}
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../libvpx/output/${NDKARCH}
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../libsvtav1/output/${NDKARCH}
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../fdk-aac/output/${NDKARCH}
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../libopus/output/${NDKARCH}
  export LDFLAGS=${LDFLAGS}" -L"${SRCFOLDER}/../vvenc/output/${NDKARCH}

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

  #vulkan は、vulkan_core.h が、277以上

  if [ "${ARCH}" = "arm" ]; then
    EXTCODEC='--enable-libx265
           --enable-libsvtav1
           --enable-libopus
           --enable-libfdk-aac'
  elif [ "${ARCH}" = "x86_32" ]; then
    EXTCODEC='--enable-libx265
           --enable-libsvtav1
           --enable-libopus
           --enable-libfdk-aac'
  else
    EXTCODEC='--enable-libx265
           --enable-libx264
           --enable-libvpx
           --enable-libsvtav1
           --enable-libopus
           --enable-libfdk-aac
           --enable-libvvenc'
  fi

  ./configure \
        --cc=${CC} \
        --arch=${ARCH} \
        --prefix=${OUTPUT_DIR} \
        --pkg-config=`pwd`/../pkgconfig.sh \
        --extra-libs="-lm" \
        --enable-gpl \
        --enable-nonfree \
        --enable-cross-compile \
        --enable-pic \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffmpeg \
        --disable-programs \
        --disable-doc \
        --disable-htmlpages \
        --disable-manpages \
        --disable-podpages \
        --disable-txtpages \
        --disable-iconv \
        --disable-xlib \
        --disable-amf           \
        --disable-audiotoolbox  \
        --disable-cuda-llvm     \
        --disable-cuvid         \
        --disable-d3d11va       \
        --disable-dxva2         \
        --disable-ffnvcodec     \
        --disable-libdrm        \
        --disable-nvdec         \
        --disable-nvenc         \
        --disable-v4l2-m2m      \
        --disable-vaapi         \
        --disable-vdpau         \
        --disable-videotoolbox  \
        --disable-alsa           \
        --disable-appkit         \
        --disable-avfoundation   \
        --disable-bzlib          \
        --disable-coreimage      \
        --disable-metal          \
        --disable-sndio          \
        --disable-schannel       \
        --disable-sdl2           \
        --disable-securetransport \
        --disable-xlib           \
        --disable-zlib           \
        --disable-devices        \
        --disable-vulkan        \
        ${EXTCODEC}

  ${MAKE}
  mkdir -p ${OUTPUT_DIR}/${NDKARCH}

  find . -name '*.a' -print | xargs -I % -t cp % ${OUTPUT_DIR}/${NDKARCH}/.
  find . -name '*.h' | cpio -pdmu ${OUTPUT_DIR}/${NDKARCH}

  ${MAKE} clean
}

#ABI armv7a
make_android armv7a-linux-androideabi arm armeabi-v7a "" ""

#ABI aarch64
make_android aarch64-linux-android aarch64 arm64-v8a "" ""

#ABI x86
#make_android i686-linux-android x86_32 x86 "" ""

#ABI x86_64
make_android x86_64-linux-android x86_64 x86_64 "" ""