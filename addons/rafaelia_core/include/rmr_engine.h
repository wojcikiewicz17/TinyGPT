#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint32_t gate_threshold;   /* 0..255 */
    uint32_t seed;
} rmr_config_t;

typedef struct {
    uint32_t bytes_in;
    uint32_t bytes_out;
    uint32_t bytes_skipped;
    uint32_t crc32;
    uint32_t rolling_hash;
} rmr_report_t;

typedef struct {
    uint32_t threshold;
    uint32_t rolling;
    uint32_t crc32;
} rmr_engine_t;

void rmr_engine_init(rmr_engine_t* engine, const rmr_config_t* cfg);
size_t rmr_engine_run(rmr_engine_t* engine,
                      const uint8_t* input,
                      size_t input_len,
                      uint8_t* output,
                      size_t output_cap,
                      rmr_report_t* report);

#ifdef __cplusplus
}
#endif
