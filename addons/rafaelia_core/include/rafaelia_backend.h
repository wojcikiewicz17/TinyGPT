#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void vectra_pulse_init_impl(uint64_t seed);
void vectra_pulse_step_impl(int32_t c_in_q16, int32_t h_in_q16);
void vectra_pulse_collapse_impl(void);
void vectra_pulse_inject_impl(const uint8_t* data, uint32_t len);
uint64_t vectra_pulse_read_impl(uint32_t* phase,
                                uint32_t* coherence_q16,
                                uint32_t* entropy_q16,
                                uint32_t* flags);

const char* vectra_backend_name(void);

#ifdef __cplusplus
}
#endif
