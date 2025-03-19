#include <jni.h>

#include <utility>

#include "ffmpeginc.h"

#include "ndktools.h"

/*
 * FFToolsラッパー
*/
class FFTools {
protected:
    std::function<bool(FFTools&)> m_callback;
public:
    Report2 report2{};

    FFTools() {
        report2.osts = nullptr;

    }
    virtual ~FFTools() {
        if( report2.osts != nullptr ) {
            free(report2.osts);
            report2.osts = nullptr;
        }
    }

    /*
     * コンバート処理
     */
    int convert(std::vector<std::string>& arglist, std::function<bool(FFTools&)> callback = nullptr ) {
        std::vector<const char*> char_ptrs;
        char_ptrs.reserve(arglist.size());
        for (const auto& str : arglist) {
            char_ptrs.push_back(str.c_str());
        }
        auto it = char_ptrs.data();

        m_callback = std::move(callback);
        return run( (int)char_ptrs.size(),(char**)it, this, [](void* pext, int is_last_report, int64_t timer_start, int64_t cur_time, int64_t pts) {
            auto* pcapture = static_cast<FFTools*>(pext);
            output_report( &(pcapture->report2), is_last_report, timer_start, cur_time, pts);

            if( pcapture->m_callback != nullptr ) {
                return pcapture->m_callback(*pcapture) == true ? 0:-1;
            }

            return 0;
        }  );
    }

    /*
     * メディアファイル解析
    　*/
    static std::string parse( const std::string& strfilename ) {
        auto root = cJSON_CreateObject();
        ::filedump( strfilename.c_str(), root );
        char* json_str = cJSON_Print(root);
        auto result = std::string(json_str);
        free(json_str);
        cJSON_Delete(root);
        return result;
    }
};

/*
 * CPU情報
 * Android\SDK\ndk\28.0.13004108\sources\android\cpufeatures
 */
extern "C" JNIEXPORT jstring JNICALL
Java_org_dwmedia_ffmpeglibs_NativeLib_CPUInfo(
        JNIEnv* env,
        jclass thiz ) {

    //Root
    auto root = cJSON_CreateObject();

    //cpu情報
    auto cpu_json = cJSON_CreateObject();
    cJSON_AddItemToObject(root, "cpu", cpu_json);

    //各情報
    cJSON_AddNumberToObject(cpu_json, "family", android_getCpuFamily());
    cJSON_AddStringToObject(cpu_json, "features", std::to_string(android_getCpuFeatures()).c_str() );
    cJSON_AddNumberToObject(cpu_json, "count", android_getCpuCount());

    //JSON化
    auto json_str = cJSON_Print(root);
    auto result = std::string(json_str);
    free(json_str);
    cJSON_Delete(root);

    return env->NewStringUTF(result.c_str());
}

/*
 * 解析処理
 */
extern "C" JNIEXPORT jstring JNICALL
Java_org_dwmedia_ffmpeglibs_NativeLib_Parse(
        JNIEnv* env,
        jclass thiz,
        jstring jinputpath ) {

    auto inputpath = toStdString(env, jinputpath);

    auto result = FFTools::parse(inputpath);

    return env->NewStringUTF(result.c_str());
}

/*
 * 変換処理
 */
extern "C" JNIEXPORT jint JNICALL
Java_org_dwmedia_ffmpeglibs_NativeLib_Convert(
        JNIEnv* env,
        jclass thiz,
        jobjectArray  fftoolsargs,
        jobject reportcallif ) {

    auto arglist = std::vector<std::string>();
    jsize len = env->GetArrayLength(fftoolsargs);
    for (int i = 0; i < len; i++) {
        auto jstr = (jstring)(env->GetObjectArrayElement(fftoolsargs, i));
        arglist.push_back( toStdString(env, jstr));
    }

    auto progressif = env->FindClass( "org/dwmedia/ffmpeglibs/NativeLib$ProgressInterface");
    auto progressif_onProgress = env->GetMethodID(progressif, "onProgress","(Lorg/dwmedia/ffmpeglibs/NativeLib$Report2;)Z");

    auto report2 = env->FindClass( "org/dwmedia/ffmpeglibs/NativeLib$Report2");
    auto report2_const = env->GetMethodID( report2, "<init>",
                                           "(JJIIIIJJDD)V");
    auto report2_addOst = env->GetMethodID( report2, "addOst",
                                            "(Lorg/dwmedia/ffmpeglibs/NativeLib$Report2$Ost;)V");

    auto report2_ost = env->FindClass( "org/dwmedia/ffmpeglibs/NativeLib$Report2$Ost");
    auto report2_ost_const = env->GetMethodID( report2_ost, "<init>",
                                               "(IFLorg/dwmedia/ffmpeglibs/NativeLib$AVMediaType;JFZJJ)V");

    auto avmediatype = env->FindClass( "org/dwmedia/ffmpeglibs/NativeLib$AVMediaType");
    auto avmediatype_valueof = env->GetStaticMethodID(avmediatype,"valueOf","(I)Lorg/dwmedia/ffmpeglibs/NativeLib$AVMediaType;");

    FFTools fftools;
    return fftools.convert(arglist, [env,reportcallif, progressif_onProgress, report2,report2_const,report2_ost,report2_ost_const,report2_addOst,avmediatype,avmediatype_valueof](FFTools& instance) {

        auto report2_instance = env->NewObject(report2,report2_const,
                                               (jlong)instance.report2.total_size,
                                               (jlong)instance.report2.last_time,
                                               (jint)instance.report2.nb_input_files,
                                               (jint)instance.report2.nb_output_files,
                                               (jint)instance.report2.nb_filtergraphs,
                                               (jint)instance.report2.nb_decoders,
                                               (jlong)instance.report2.duration,
                                               (jlong)instance.report2.elapsed,
                                               (jdouble)instance.report2.bitrate,
                                               (jdouble)instance.report2.speed);

        for( int i=0; i<instance.report2.nb_output_files; i++ ) {

            auto avmediatype_instance = env->CallStaticObjectMethod(avmediatype,avmediatype_valueof, (jint)instance.report2.osts[i].mediatype);

            auto report2_ost_instance = env->NewObject(report2_ost,report2_ost_const,
                                                       (jint)instance.report2.osts[i].vid,
                                                       (jfloat)instance.report2.osts[i].q,
                                                       avmediatype_instance,
                                                       (jlong)instance.report2.osts[i].frame_number,
                                                       (jfloat)instance.report2.osts[i].fps,
                                                       (jboolean) (instance.report2.osts[i].outfilter == NULL ? false:true),
                                                       (jlong)instance.report2.osts[i].nb_frames_dup,
                                                       (jlong)instance.report2.osts[i].nb_frames_drop);
            env->CallVoidMethod( report2_instance, report2_addOst, report2_ost_instance );

            //ローカル参照減算
            env->DeleteLocalRef(report2_ost_instance);
            env->DeleteLocalRef(avmediatype_instance);
        }

        auto result = env->CallBooleanMethod( reportcallif, progressif_onProgress, report2_instance );
        //Report2後片付け
        env->DeleteLocalRef(report2_instance);

        return result;
    } );

}
