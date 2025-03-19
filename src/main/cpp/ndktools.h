//
// Created by nosaka on 2022/06/07.
//

#ifndef FFMPEGTEST_NDKTOOLS_H
#define FFMPEGTEST_NDKTOOLS_H

#include <jni.h>

#include "android/log.h"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, "TAG", __VA_ARGS__)
#define LOGV(...) __android_log_print(ANDROID_LOG_VERBOSE, "TAG", __VA_ARGS__)

/*
 * jstring 変換
 */
std::string toStdString(JNIEnv *env,jstring& jstr );

/*
 * 文字列応答メソッド string変換
 */
std::string FromJNIMethodToString( JNIEnv* env, jclass jclasstype, std::string methodname, jobject instance, ... );


#endif //FFMPEGTEST_NDKTOOLS_H
