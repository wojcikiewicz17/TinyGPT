#include "rmr_engine.h"

#include <string.h>

static uint8_t rmr_token_table[256];
static uint32_t rmr_crc_table[256];
static int rmr_tables_ready = 0;

static inline uint32_t rmr_rotl32(uint32_t x, uint32_t n) {
    return (x << n) | (x >> (32u - n));
}

static void rmr_prepare_tables(void) {
    if (rmr_tables_ready) {
        return;
    }

    for (uint32_t i = 0; i < 256; ++i) {
        uint8_t v = (uint8_t)i;
        uint8_t alpha = (uint8_t)(v | 0x20u);
        uint8_t is_letter = (uint8_t)((alpha >= 'a') & (alpha <= 'z'));
        rmr_token_table[i] = (uint8_t)(v ^ (is_letter * 0x20u));
    }

    for (uint32_t i = 0; i < 256; ++i) {
        uint32_t c = i;
        for (uint32_t b = 0; b < 8; ++b) {
            uint32_t m = (uint32_t)(-(int32_t)(c & 1u));
            c = (c >> 1u) ^ (0xEDB88320u & m);
        }
        rmr_crc_table[i] = c;
    }

    rmr_tables_ready = 1;
}

void rmr_engine_init(rmr_engine_t* engine, const rmr_config_t* cfg) {
    rmr_prepare_tables();
    if (engine == NULL) {
        return;
    }

    const uint32_t threshold = (cfg != NULL) ? (cfg->gate_threshold & 0xFFu) : 160u;
    const uint32_t seed = (cfg != NULL) ? cfg->seed : 0xA5A5F00Du;

    engine->threshold = threshold;
    engine->rolling = seed;
    engine->crc32 = 0xFFFFFFFFu;
}

size_t rmr_engine_run(rmr_engine_t* engine,
                      const uint8_t* input,
                      size_t input_len,
                      uint8_t* output,
                      size_t output_cap,
                      rmr_report_t* report) {
    if (engine == NULL || input == NULL || output == NULL || output_cap == 0) {
        return 0;
    }

    uint32_t rolling = engine->rolling;
    uint32_t crc = engine->crc32;
    const uint32_t threshold = engine->threshold;

    size_t out_n = 0;
    uint32_t skipped = 0;

    for (size_t i = 0; i < input_len; ++i) {
        const uint8_t token = rmr_token_table[input[i]];

        const uint32_t phi_hash = (uint32_t)(((uint64_t)token * 0x9E3779B9u) >> 8u);
        const uint32_t score = (phi_hash ^ rolling) & 0xFFu;

        const uint32_t pass = (uint32_t)(score >= threshold);
        const uint8_t mask = (uint8_t)(-(int32_t)pass);

        const uint8_t mixed = (uint8_t)(rmr_rotl32(token, 1u) ^ (rolling & 0xFFu));
        const uint8_t outv = (uint8_t)(mixed & mask);

        if ((pass != 0u) && (out_n < output_cap)) {
            output[out_n++] = outv;
        } else {
            skipped += 1u;
        }

        rolling ^= phi_hash + 0x7F4A7C15u;
        rolling = rmr_rotl32(rolling, 5u);

        const uint32_t idx = (crc ^ outv) & 0xFFu;
        crc = (crc >> 8u) ^ rmr_crc_table[idx];
    }

    engine->rolling = rolling;
    engine->crc32 = crc;

    if (report != NULL) {
        report->bytes_in = (uint32_t)input_len;
        report->bytes_out = (uint32_t)out_n;
        report->bytes_skipped = skipped;
        report->crc32 = crc ^ 0xFFFFFFFFu;
        report->rolling_hash = rolling;
    }

    return out_n;
}
