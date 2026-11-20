ENTRY(kernel_main)

SECTIONS {
    . = 1M;

    .text BLOCK(4K) : ALIGN(4K) {
        KEEP(*(.multiboot))
        *(.text*)
    }

    .rodata BLOCK(4K) : ALIGN(4K) {
        *(.rodata*)
        *(.rdata*)
    }

    .data BLOCK(4K) : ALIGN(4K) {
        *(.data*)
    }

    .bss BLOCK(4K) : ALIGN(4K) {
        *(COMMON)
        *(.bss*)
    }

    /DISCARD/ : {
        *(.eh_frame*)
        *(.pdata*)
        *(.xdata*)
        *(.reloc*)
    }
}
