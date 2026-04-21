.text

#if defined(__x86_64__)

.bss
.align 8
geolm_state:
    .quad 0

.global geolm_init
.type geolm_init, %function
geolm_init:
    mov %rdi, geolm_state(%rip)
    ret

.global geolm_step
.type geolm_step, %function
geolm_step:
    mov geolm_state(%rip), %rax
    xor %rdi, %rax
    add %rsi, %rax
    rol $13, %rax
    movabs $0x9e3779b97f4a7c15, %rdx
    xor %rdx, %rax
    mov %rax, geolm_state(%rip)
    ret

.global geolm_score
.type geolm_score, %function
geolm_score:
    mov %rdi, %rax
    shr $32, %rax
    xor %edi, %eax
    ret

#elif defined(__aarch64__)

.bss
.align 8
geolm_state:
    .xword 0

.global geolm_init
.type geolm_init, %function
geolm_init:
    adrp x9, geolm_state
    add x9, x9, :lo12:geolm_state
    str x0, [x9]
    ret

.global geolm_step
.type geolm_step, %function
geolm_step:
    adrp x9, geolm_state
    add x9, x9, :lo12:geolm_state
    ldr x10, [x9]
    eor x10, x10, x0
    add x10, x10, x1
    ror x10, x10, #51
    mov x11, #0x7c15
    movk x11, #0x7f4a, lsl #16
    movk x11, #0xb97f, lsl #32
    movk x11, #0x9e37, lsl #48
    eor x10, x10, x11
    str x10, [x9]
    mov x0, x10
    ret

.global geolm_score
.type geolm_score, %function
geolm_score:
    lsr x1, x0, #32
    eor w0, w0, w1
    ret

#else
#error "GeoLM ASM core currently supports x86_64 and aarch64"
#endif
