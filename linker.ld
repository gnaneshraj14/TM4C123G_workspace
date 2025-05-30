/* linker.ld */
MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    RAM   (rwx): ORIGIN = 0x20000000, LENGTH = 32K
}

/* symbols defined by the linker for data init */
PROVIDE(__etext = LOADADDR(.text) + SIZEOF(.text));
PROVIDE(__data_start__ = ORIGIN(RAM));
PROVIDE(__data_end__   = ORIGIN(RAM) + SIZEOF(.data));
PROVIDE(__bss_start__  = ORIGIN(RAM) + SIZEOF(.data));
PROVIDE(__bss_end__    = ORIGIN(RAM) + SIZEOF(.bss));

_estack = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
    .vectors : ALIGN(4)
    {
        KEEP(*(.vectors))
    } > FLASH

    .text : ALIGN(4)
    {
        *(.text*)
        *(.rodata*)
    } > FLASH

    .data : ALIGN(4)
    {
        *(.data*)
    } > RAM AT> FLASH

    .bss  : ALIGN(4)
    {
        *(.bss*)
        *(COMMON)
    } > RAM

    /* optional: small stack overflow guard page */
    .stack_fill : AT(ADDR(.bss) + SIZEOF(.bss)) {
      . = ALIGN(8);
      PROVIDE(__stack_limit = .);
    } > RAM
}

