.section .vectors
vector_table:
    .word 0x00000000
    .word reset_handler
    .zero 400

    .section .text
    .align 1
    .type reset_handler, %function
reset_handler:
	bl .


