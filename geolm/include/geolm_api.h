#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void geolm_init(uint64_t seed);
uint64_t geolm_step(uint64_t token, uint64_t state);
uint32_t geolm_score(uint64_t state);

#ifdef __cplusplus
}
#endif
