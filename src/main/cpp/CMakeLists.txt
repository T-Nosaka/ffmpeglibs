# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html.
# For more examples on how to use CMake, see https://github.com/android/ndk-samples.

# Sets the minimum CMake version required for this project.
cmake_minimum_required(VERSION 3.22.1)

# Declares the project name. The project name can be accessed via ${ PROJECT_NAME},
# Since this is the top level CMakeLists.txt, the project name is also accessible
# with ${CMAKE_PROJECT_NAME} (both CMake variables are in-sync within the top level
# build script scope).
project("ffmpeglibs")

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

#external Library path
set( cJSON_DIR ${PROJECT_SOURCE_DIR}/../cJSON/output )
set( libx265_DIR ${PROJECT_SOURCE_DIR}/../libx265/output)
set( libx264_DIR ${PROJECT_SOURCE_DIR}/../libx264/output)
set( vvenc_DIR ${PROJECT_SOURCE_DIR}/../vvenc/output)
set( libvpx_DIR ${PROJECT_SOURCE_DIR}/../libvpx/output)
set( libsvtav1_DIR ${PROJECT_SOURCE_DIR}/../libsvtav1/output)
set( fdkaac_DIR ${PROJECT_SOURCE_DIR}/../fdk-aac/output)
set( libopus_DIR ${PROJECT_SOURCE_DIR}/../libopus/output)
set( ffmpeg_DIR ${PROJECT_SOURCE_DIR}/../ffmpeg/output)
set( ffmpeg71_DIR ${PROJECT_SOURCE_DIR}/../ffmpeg/FFmpeg-n7.1)
set( fftools_DIR ${PROJECT_SOURCE_DIR}/../ffmpeg/FFmpeg-n7.1/fftools)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.
#
# In this top level CMakeLists.txt, ${CMAKE_PROJECT_NAME} is used to define
# the target library name; in the sub-module's CMakeLists.txt, ${PROJECT_NAME}
# is preferred for the same purpose.
#
# In order to load a library into your app from Java/Kotlin, you must call
# System.loadLibrary() and pass the name of the library defined here;
# for GameActivity/NativeActivity derived applications, the same library name must be
# used in the AndroidManifest.xml file.
add_library(${CMAKE_PROJECT_NAME} SHARED
        # List C/C++ source files with relative paths to this CMakeLists.txt.
        ndktools.cpp
        cpu-features.c
        ffmpeglibs.cpp
        ${fftools_DIR}/cmdutils.c
        ${fftools_DIR}/ffmpeg_dec.c
        ${fftools_DIR}/ffmpeg_demux.c
        ${fftools_DIR}/ffmpeg_enc.c
        ${fftools_DIR}/ffmpeg_filter.c
        ${fftools_DIR}/ffmpeg_hw.c
        ${fftools_DIR}/ffmpeg_mux.c
        ${fftools_DIR}/ffmpeg_mux_init.c
        ${fftools_DIR}/ffmpeg_opt.c
        ${fftools_DIR}/ffmpeg_sched.c
        ${fftools_DIR}/objpool.c
        ${fftools_DIR}/opt_common.c
        ${fftools_DIR}/sync_queue.c
        ${fftools_DIR}/thread_queue.c
        run.c
        )

#set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)
set(CMAKE_VERBOSE_MAKEFILE on)
set(CMAKE_CXX_FLAGS "-D __STDC_CONSTANT_MACROS -Wregister -Wno-error=reserved-user-defined-literal")

set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-Bsymbolic")

#Etc libs
add_library(cjson STATIC IMPORTED)
set_target_properties(cjson PROPERTIES IMPORTED_LOCATION ${cJSON_DIR}/${ANDROID_ABI}/libcjson.a)

#Video codec
add_library(x265 STATIC IMPORTED)
set_target_properties(x265 PROPERTIES IMPORTED_LOCATION ${libx265_DIR}/${ANDROID_ABI}/libx265.a)
add_library(x264 STATIC IMPORTED)
set_target_properties(x264 PROPERTIES IMPORTED_LOCATION ${libx264_DIR}/${ANDROID_ABI}/libx264.a)
add_library(vvenc STATIC IMPORTED)
set_target_properties(vvenc PROPERTIES IMPORTED_LOCATION ${vvenc_DIR}/${ANDROID_ABI}/libvvenc.a)
add_library(vpx STATIC IMPORTED)
set_target_properties(vpx PROPERTIES IMPORTED_LOCATION ${libvpx_DIR}/${ANDROID_ABI}/libvpx.a)
add_library(svtav1 STATIC IMPORTED)
set_target_properties(svtav1 PROPERTIES IMPORTED_LOCATION ${libsvtav1_DIR}/${ANDROID_ABI}/libSvtAv1Enc.a)
#Audio codec
add_library(fdk-aac STATIC IMPORTED)
set_target_properties(fdk-aac PROPERTIES IMPORTED_LOCATION ${fdkaac_DIR}/${ANDROID_ABI}/libfdk-aac.a)
add_library(opus STATIC IMPORTED)
set_target_properties(opus PROPERTIES IMPORTED_LOCATION ${libopus_DIR}/${ANDROID_ABI}/libopus.a)

#ffmpeg
add_library(avcodec STATIC IMPORTED)
set_target_properties(avcodec PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libavcodec.a)
add_library(avdevice STATIC IMPORTED)
set_target_properties(avdevice PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libavdevice.a)
add_library(avfilter STATIC IMPORTED)
set_target_properties(avfilter PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libavfilter.a)
add_library(avformat STATIC IMPORTED)
set_target_properties(avformat PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libavformat.a)
add_library(avutil STATIC IMPORTED)
set_target_properties(avutil PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libavutil.a)
add_library(postproc STATIC IMPORTED)
set_target_properties(postproc PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libpostproc.a)
add_library(swresample STATIC IMPORTED)
set_target_properties(swresample PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libswresample.a)
add_library(swscale STATIC IMPORTED)
set_target_properties(swscale PROPERTIES IMPORTED_LOCATION ${ffmpeg_DIR}/${ANDROID_ABI}/libswscale.a)

find_package (Threads)

# Specifies libraries CMake should link to your target library. You
# can link libraries from various origins, such as libraries defined in this
# build script, prebuilt third-party libraries, or Android system libraries.
if(${ANDROID_ABI} STREQUAL "arm64-v8a" OR ${ANDROID_ABI} STREQUAL "x86_64" )
    target_link_libraries(${CMAKE_PROJECT_NAME}
            # List libraries link to the target library
            avcodec
            avdevice
            avfilter
            avformat
            avutil
            postproc
            swresample
            swscale
            cjson
            x265
            x264
            vvenc
            svtav1
            vpx
            fdk-aac
            opus
            android
            log)
else()
    target_link_libraries(${CMAKE_PROJECT_NAME}
            # List libraries link to the target library
            avcodec
            avdevice
            avfilter
            avformat
            avutil
            postproc
            swresample
            swscale
            cjson
            x265
            svtav1
            fdk-aac
            opus
            android
            log)
endif()

include_directories( ${ffmpeg_DIR}/${ANDROID_ABI}/ ${fftools_DIR} ${ffmpeg71_DIR}/compat/stdbit ${cJSON_DIR}/${ANDROID_ABI} )
