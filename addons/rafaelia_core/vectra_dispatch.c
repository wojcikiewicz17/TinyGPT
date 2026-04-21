#include "include/rafaelia_contract.h"
#include "include/rafaelia_backend.h"

void vectra_pulse_init(uint64_t seed) {
    vectra_pulse_init_impl(seed);
}

void vectra_pulse_step(int32_t c_in_q16, int32_t h_in_q16) {
    vectra_pulse_step_impl(c_in_q16, h_in_q16);
}

void vectra_pulse_collapse(void) {
    vectra_pulse_collapse_impl();
}

void vectra_pulse_inject(const uint8_t* data, uint32_t len) {
    vectra_pulse_inject_impl(data, len);
}

uint64_t vectra_pulse_read(uint32_t* phase,
                           uint32_t* coherence_q16,
                           uint32_t* entropy_q16,
                           uint32_t* flags) {
    return vectra_pulse_read_impl(phase, coherence_q16, entropy_q16, flags);
}
