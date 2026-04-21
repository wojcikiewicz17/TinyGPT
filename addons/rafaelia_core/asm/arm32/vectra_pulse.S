/* =============================================================================
 * RAFAELIA / VECTRA PULSE (ARMv7-A, sem dependências externas)
 * ============================================================================= */

.syntax unified
.arm
.text
.align 5

.global vectra_pulse_init_impl
.global vectra_pulse_step_impl
.global vectra_pulse_collapse_impl
.global vectra_pulse_inject_impl
.global vectra_pulse_read_impl
.global vectra_backend_name

.equ OFF_SEED,       0
.equ OFF_ACC,        8
.equ OFF_PHASE,      16
.equ OFF_COH,        20
.equ OFF_ENT,        24
.equ OFF_FLAGS,      28
.equ STATE_SIZE,     32

.equ Q16_HALF,       0x8000
.equ Q16_DELTA_OK,   0x0800
.equ PERIOD_42,      42

vectra_pulse_init_impl:
    ldr r1, =vectra_state
    str r0, [r1, #OFF_SEED]
    str r0, [r1, #OFF_ACC]
    eor r2, r0, #0x1B3
    str r2, [r1, #OFF_ACC]
    mov r2, #0
    str r2, [r1, #OFF_PHASE]
    movw r2, #Q16_HALF
    str r2, [r1, #OFF_COH]
    str r2, [r1, #OFF_ENT]
    mov r2, #0
    str r2, [r1, #OFF_FLAGS]
    bx lr

vectra_pulse_step_impl:
    ldr r2, =vectra_state
    ldr r3, [r2, #OFF_COH]
    ldr r12, [r2, #OFF_ENT]

    add r3, r3, r3, lsl #1
    add r3, r3, r0
    asr r3, r3, #2

    add r12, r12, r12, lsl #1
    add r12, r12, r1
    asr r12, r12, #2

    str r3, [r2, #OFF_COH]
    str r12, [r2, #OFF_ENT]

    ldr r4, [r2, #OFF_PHASE]
    add r4, r4, #1
    cmp r4, #PERIOD_42
    movge r4, #0
    str r4, [r2, #OFF_PHASE]

    ldr r5, [r2, #OFF_ACC]
    eor r5, r5, r5, lsl #13
    eor r5, r5, r5, lsr #7
    eor r5, r5, r5, lsl #17
    eor r5, r5, r3
    ror r5, r5, #11
    add r5, r5, r12
    str r5, [r2, #OFF_ACC]
    bx lr

vectra_pulse_collapse_impl:
    ldr r0, =vectra_state
    ldr r1, [r0, #OFF_COH]
    ldr r2, [r0, #OFF_ENT]
    subs r3, r1, r2
    rsbmi r3, r3, #0

    mov r4, #1
    mov r5, #2
    cmp r3, #Q16_DELTA_OK
    movle r6, r4
    movgt r6, r5
    str r6, [r0, #OFF_FLAGS]

    ldr r7, [r0, #OFF_ACC]
    eor r7, r7, r3, lsl #16
    eor r7, r7, r6
    str r7, [r0, #OFF_ACC]
    bx lr

vectra_pulse_inject_impl:
    cmp r1, #0
    bxeq lr

    ldr r2, =vectra_state
    ldr r3, [r2, #OFF_ACC]
    ldr r12, =0x01000193
1:
    ldrb r4, [r0], #1
    eor r3, r3, r4
    mul r3, r12, r3
    subs r1, r1, #1
    bne 1b
    str r3, [r2, #OFF_ACC]

    ldr r4, [r2, #OFF_PHASE]
    and r5, r3, #0x1f
    add r4, r4, r5
2:
    cmp r4, #PERIOD_42
    blt 3f
    sub r4, r4, #PERIOD_42
    b 2b
3:
    str r4, [r2, #OFF_PHASE]
    bx lr

vectra_pulse_read_impl:
    push {r4-r7, lr}
    ldr r4, =vectra_state
    ldr r5, [r4, #OFF_PHASE]
    ldr r6, [r4, #OFF_COH]
    ldr r7, [r4, #OFF_ENT]
    ldr r12, [r4, #OFF_FLAGS]

    cmp r0, #0
    strne r5, [r0]
    cmp r1, #0
    strne r6, [r1]
    cmp r2, #0
    strne r7, [r2]
    cmp r3, #0
    strne r12, [r3]

    ldr r0, [r4, #OFF_ACC]
    mov r1, #0
    pop {r4-r7, pc}

vectra_backend_name:
    ldr r0, =backend_name_arm32
    bx lr

.align 5
.bss
vectra_state:
    .space STATE_SIZE

.section .rodata
backend_name_arm32:
    .asciz "arm32-asm"
