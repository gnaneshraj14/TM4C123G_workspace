MEMORY
{
    FLASH : ORIGIN = 0x00000000, LENGTH = 0x4000
    RAM : ORIGIN = 0x20000000, LENGTH = 0x8000
}

SECTIONS
{
    .text : {
        *(.vectors*)
        *(.text*)
    } > FLASH

    .data : {
        *(.data*)
    } > RAM
}
