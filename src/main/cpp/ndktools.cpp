//
// Created by nosaka on 2022/06/07.
//
#include <jni.h>
#include <string>

/*
 * jstring 変換
 */
std::string toStdString(JNIEnv *env,jstring& jstr ) {
    jboolean b;
    auto jstrchar = env->GetStringUTFChars(jstr, &b);
    std::string repopath = jstrchar;
    env->ReleaseStringUTFChars(jstr, jstrchar);
    return repopath;
}

/*
 * 文字列応答メソッド string変換
 */
std::string FromJNIMethodToString( JNIEnv* env, jclass jclasstype, std::string methodname, jobject instance, ... ) {
    auto getMethodId = env->GetMethodID( jclasstype, methodname.c_str(), "()Ljava/lang/String;");

    va_list args;
    va_start(args, instance);
    auto resultjstring = static_cast<jstring>(env->CallObjectMethod(instance,getMethodId, args));
    va_end(args);

    return toStdString(env,resultjstring);
}