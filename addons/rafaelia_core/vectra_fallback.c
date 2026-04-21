#include "include/rafaelia_backend.h"

#include <stddef.h>

typedef struct {
    uint64_t seed;
    uint64_t acc;
    uint32_t phase;
    uint32_t coherence_q16;
    uint32_t entropy_q16;
    uint32_t flags;
} vectra_state_t;

static vectra_state_t g_state;

static uint32_t q16_blend(uint32_t current, int32_t incoming) {
    const int32_t in = incoming;
    const int32_t cur = (int32_t)current;
    return (uint32_t)(((cur * 3) + in) >> 2);
}

void vectra_pulse_init_impl(uint64_t seed) {
    g_state.seed = seed;
    g_state.acc = seed ^ 0x100000001B3ULL;
    g_state.phase = 0u;
    g_state.coherence_q16 = 0x8000u;
    g_state.entropy_q16 = 0x8000u;
    g_state.flags = 0u;
}

void vectra_pulse_step_impl(int32_t c_in_q16, int32_t h_in_q16) {
    g_state.coherence_q16 = q16_blend(g_state.coherence_q16, c_in_q16);
    g_state.entropy_q16 = q16_blend(g_state.entropy_q16, h_in_q16);
    g_state.phase = (g_state.phase + 1u) % 42u;

    g_state.acc ^= g_state.acc << 13u;
    g_state.acc ^= g_state.acc >> 7u;
    g_state.acc ^= g_state.acc << 17u;
    g_state.acc ^= (uint64_t)g_state.coherence_q16;
    g_state.acc += (uint64_t)g_state.entropy_q16;
}

void vectra_pulse_collapse_impl(void) {
    const int32_t c = (int32_t)g_state.coherence_q16;
    const int32_t h = (int32_t)g_state.entropy_q16;
    const uint32_t delta = (uint32_t)((c >= h) ? (c - h) : (h - c));

    g_state.flags = (delta <= 0x0800u) ? 1u : 2u;
    g_state.acc ^= ((uint64_t)delta << 16u) ^ (uint64_t)g_state.flags;
}

void vectra_pulse_inject_impl(const uint8_t* data, uint32_t len) {
    if (data == NULL || len == 0u) {
        return;
    }

    uint64_t acc = g_state.acc;
    for (uint32_t i = 0; i < len; ++i) {
        acc ^= (uint64_t)data[i];
        acc *= 0x100000001B3ULL;
    }
    g_state.acc = acc;
    g_state.phase = (g_state.phase + (acc & 0x1Fu)) % 42u;
}

uint64_t vectra_pulse_read_impl(uint32_t* phase,
                                uint32_t* coherence_q16,
                                uint32_t* entropy_q16,
                                uint32_t* flags) {
    if (phase != NULL) {
        *phase = g_state.phase;
    }
    if (coherence_q16 != NULL) {
        *coherence_q16 = g_state.coherence_q16;
    }
    if (entropy_q16 != NULL) {
        *entropy_q16 = g_state.entropy_q16;
    }
    if (flags != NULL) {
        *flags = g_state.flags;
    }
    return g_state.acc;
}

const char* vectra_backend_name(void) {
#if defined(__aarch64__)
    return "arm64-fallback-c";
#elif defined(__arm__)
    return "arm32-fallback-c";
#else
    return "portable-c";
#endif
}
