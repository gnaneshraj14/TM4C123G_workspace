ENTRY(_boot)

MEMORY
{
    RAM (xrw) : ORIGIN = 0x20000000, LENGTH = 0x800
    VECTORS (rx) : ORIGIN = 0x00000000, LENGTH = 0x100
}

SECTIONS
{
    .isr_vector : {
        KEEP(*(.isr_vector))
    } > VECTORS

    .text : {
        *(.text*)
        *(.rodata*)
    } > RAM

    .data : { *(.data*) } > RAM
    .bss : { *(.bss*) *(COMMON) } > RAM
}
