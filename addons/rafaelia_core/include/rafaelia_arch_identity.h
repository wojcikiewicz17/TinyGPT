#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef RAFAELIA_ARCH_ID_HEX
#define RAFAELIA_ARCH_ID_HEX 0xA00000FFu
#endif

/* 7 identidades primárias de arquitetura, codificadas em hexadecimal */
#define RAFAELIA_ARCH_ARM64_HEX   0xA0640001u
#define RAFAELIA_ARCH_ARM32_HEX   0xA0320002u
#define RAFAELIA_ARCH_X86_HEX     0xA0860003u
#define RAFAELIA_ARCH_X86_64_HEX  0xA8640004u
#define RAFAELIA_ARCH_RISCV64_HEX 0xA7640005u
#define RAFAELIA_ARCH_PPC64LE_HEX 0xAC640006u
#define RAFAELIA_ARCH_S390X_HEX   0xA3900007u

uint32_t rmr_arch_identity_hex(void);

#ifdef __cplusplus
}
#endif
