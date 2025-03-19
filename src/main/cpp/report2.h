#ifndef REPORT2_H
#define REPORT2_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "libavutil/avutil.h"

typedef struct report2_ost {
    int vid;
    float q;
    enum AVMediaType mediatype;
    uint64_t frame_number;
    float fps;

    void* outfilter;
    uint64_t nb_frames_dup;
    uint64_t nb_frames_drop;
} Report2_ost;

typedef struct report2 {
    int64_t total_size ;
    int64_t last_time ;

    int nb_input_files;
    int nb_output_files;
    int nb_filtergraphs;
    int nb_decoders;

    Report2_ost* osts;

    uint64_t duration;
    uint64_t elapsed;
    double bitrate;
    double speed;

} Report2 ;

void output_report(Report2* rep, int is_last_report, int64_t timer_start, int64_t cur_time, int64_t pts);

#ifdef __cplusplus
}
#endif

#endif
