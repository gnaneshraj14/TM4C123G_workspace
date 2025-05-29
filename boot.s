.syntax unified
.cpu cortex-m3
.thumb

.section .isr_vector, "a", %progbits
.word   0x20001000      // Initial stack pointer (top of RAM)
.word   _boot           // Reset vector

.section .text._boot
.global _boot
.type _boot, %function

_boot:
    //LDR   R0, =0x20001000
    //MSR   MSP, R0
    //MOV R0, #5
    //MOV R1, #14
    //ADD R3, R1, R0
    //BL    main
    //B     .             // Infinite loop after main returns
    // testing asm code
	push	{r7}
	sub	sp, sp, #12
	add	r7, sp, #0
	movs	r3, #10
	str	r3, [r7, #4]
	movs	r3, #2
	str	r3, [r7]
	ldr	r3, [r7, #4]
	cmp	r3, #10
	bne	.L2
	ldr	r3, [r7]
	adds	r3, r3, #200
	str	r3, [r7]
	b	.L1
.L2:
	ldr	r3, [r7]
	subs	r3, r3, #200
	str	r3, [r7]
	nop
.L1:
	adds	r7, r7, #12
	mov	sp, r7
	pop	{r7}
	bx	lr
