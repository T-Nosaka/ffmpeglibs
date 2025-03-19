#ifndef FFMPEGINC_H
#define FFMPEGINC_H

#include <iostream>
#include <string>
#include <vector>
#include <functional>

#include <inttypes.h>

#include "UsingBlock.h"
#include "stringformat.h"

extern "C"{

    #include "config.h"
    #include "config_components.h"

    #include "libavformat/avformat.h"
    #include "libavcodec/avcodec.h"
    #include "libavutil/imgutils.h"
    #include "libavutil/opt.h"
    #include "libswscale/swscale.h"
    #include "libswresample/swresample.h"
    #include "libavdevice/avdevice.h"

    #include "cJSON.h"

    #include "report2.h"

    #include "cpu-features.h"

    void filedump( const char *filename, cJSON* root );
    int run(int argc, char **argv, void* pext, int (*callback)(void* pext, int is_last_report, int64_t timer_start, int64_t cur_time, int64_t pts));

}

#endif