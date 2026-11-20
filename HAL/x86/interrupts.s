/* Copyright 2026-present Evgeny Zoshchuk (JordanCpp) | GNU GPLv3 (https://gnu.org) */

.intel_syntax noprefix

.section .text
.global irq0_handler
.global irq1_handler
.extern common_interrupt_logic

.macro ISR_WRAPPER name, vector
    .global \name
    \name:
        pushad
        push ds
        push es

        push \vector
        call common_interrupt_logic
        add esp, 4

        pop es
        pop ds
        popad
        iret
.endm

ISR_WRAPPER irq0_handler, 32
ISR_WRAPPER irq1_handler, 33
