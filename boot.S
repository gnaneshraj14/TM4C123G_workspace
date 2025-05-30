

/*.section .vectors
vector_table:
    .word 0x00000000
    .word reset_handler
    .zero 400

    .section .text
    .align 1
    .type reset_handler, %function
reset_handler:
	bl . */


    .syntax unified
    .cpu cortex-m4
    .thumb

    /* Vector table */
    .section .vectors, "a", %progbits
    .align  2
    .word   _estack           /* initial SP */
    .word   reset_handler     /* reset vector */

    /* Reset handler */
    .section .text
    .align  1
    .global reset_handler
    .type   reset_handler, %function
reset_handler:
    /* Copy .data from flash (at __etext) to RAM (from __data_start__ to __data_end__) */
    ldr   r0, =__etext        /* source in FLASH */
    ldr   r1, =__data_start__ /* dest in SRAM */
    ldr   r2, =__data_end__
copy_loop:
    cmp   r1, r2
    ittt  lt
    ldrlt r3, [r0], #4        /* r3 = *r0; r0 += 4 */
    strlt r3, [r1], #4        /* *r1 = r3; r1 += 4 */
    blt   copy_loop

    /* Zero .bss (from __bss_start__ to __bss_end__) */
    ldr   r0, =__bss_start__
    ldr   r1, =__bss_end__
    movs  r3, #0              /* prepare zero in r3 */
bss_loop:
    cmp   r0, r1
    it    lt
    strlt r3, [r0], #4        /* *r0 = 0; r0 += 4 */
    blt   bss_loop

    /* Call main() */
    bl    main

hang:
    b     hang


