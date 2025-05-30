

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

    .section .vectors, "a", %progbits
    .align  2
    .word   _estack           /* initial stack pointer */
    .word   reset_handler     /* reset vector */
    /* .word   NMI_Handler
       .word   HardFault_Handler
       ... etc ... */

    .section .text
    .align  1
    .global reset_handler
    .type reset_handler, %function
reset_handler:
    /* 1. copy .data from flash to RAM */
    ldr   r0, =__etext
    ldr   r1, =__data_start__
    ldr   r2, =__data_end__
1:  cmp   r1, r2
    ittt  lt
    ldrlt r3, [r0], #4
    strlt r3, [r1], #4
    blt   1b

    /* 2. zero .bss */
    ldr   r0, =__bss_start__
    ldr   r1, =__bss_end__
2:  cmp   r0, r1
    it   lt
    strlt r0, [r0], #4
    blt   2b

    /* 3. call main() */
    bl    main

hang:
    b     hang


