
PROJECT = boot
CPU     ?= cortex-m4
BOARD   ?= stm32vldiscovery

.PHONY: all qemu gdb clean asm clean-asm

# 1) Generate the "verbose" assembly (with comments)
asm: c-asm.c
	@echo "Generating verbose assembly: c-asm.s from c-asm.c"
	arm-none-eabi-gcc \
	  -mcpu=$(CPU) -mthumb -O0 -nostdlib \
	  -S c-asm.c -o c-asm.s

# 2) Produce a stripped-down version with only instructions (no .directives or comments)
c-pppure-asm:
	@echo "Producing stripped assembly: pure-clean.s"
	sed '/^\s*\./d' c-asm.s > pure-asm.s

c-pure-asm:
	@echo "Generating complete aligned assembly (all functions, no directives): pure-asm.s"
	@expand -t 8 c-asm.s | \
	awk ' \
	function rtrim(s) { sub(/[ \t]+$$/, "", s); return s } \
	/^\s*\..*/ { if ($$1 ~ /^\.L/) print $$0; next } \
	/^\s*@/ { print rtrim($$0); next } \
	/^[a-zA-Z_\.][a-zA-Z0-9_\.]*:/ { print $$0; next } \
	/^[ \t]*(push|pop|mov|movs|cmp|ldr|str|bne|beq|b|bx|bl|blx|adds|subs|sub|nop)/ { \
	    if ($$0 ~ /@/) { \
	        split($$0, parts, "@"); \
	        printf "%-40s@ %s\n", rtrim(parts[1]), rtrim(parts[2]); \
	    } else { print $$0 } \
	    next \
	}' > pure-asm.s

# produces color asm code in the terminal
color-asm:
	@echo "Generating syntax-colored assembly in terminal:"
	@cat pure-asm.s | \
	sed -E 's/\b(b|bne|beq|bl|bx)\b/\x1b[34m&\x1b[0m/g' | \
	sed -E 's/\b(add|adds|sub|subs|cmp|movs)\b/\x1b[32m&\x1b[0m/g' | \
	sed -E 's/\b(ldr|str|mov|push|pop)\b/\x1b[35m&\x1b[0m/g' | \
	sed -E 's/\b(nop)\b/\x1b[90m&\x1b[0m/g'

# produces very very very raw asm code
raw-asm:
	@echo "Producing stripped assembly: c-asm-clean.s"
	sed '/^\s*\./d; s/@.*$$//; /^[[:space:]]*$$/d' c-asm.s > c-asm-clean.s

# produces raw asm code with some comments and inline <---- suggested to use
pure-asm:
	@echo "Producing final aligned assembly: pure-asm.s"
	@expand -t 8 c-asm.s | \
	sed -n '/^cmain:/,$$p' | \
	sed '/^\s*\./d' | \
	awk ' \
	function rtrim(s) { sub(/[ \t]+$$/, "", s); return s } \
	{ \
	  if ($$0 ~ /@/) { \
	    split($$0, parts, "@"); \
	    printf "%-40s@ %s\n", rtrim(parts[1]), parts[2]; \
	  } else { print $$0 } \
	}' > pure-asm.s

# 3) Full build: assemble .s + compile .c + link + run QEMU
qemu: boot.s main.c
	@echo "Assembling: boot.s → boot.o"
	arm-none-eabi-as -mcpu=$(CPU) -mthumb -ggdb -o boot.o boot.s

	@echo "Compiling: main.c → main.o"
	arm-none-eabi-gcc -mcpu=$(CPU) -mthumb -c -nostdlib -ffreestanding -ggdb main.c -o main.o

	@echo "Linking: boot.o + main.o → boot.elf"
	arm-none-eabi-ld -Tmap.ld boot.o main.o -o boot.elf

	@echo "Generating disassembly: boot.elf.lst"
	arm-none-eabi-objdump -D -S boot.elf > boot.elf.lst

	@echo "Generating debug dump: boot.elf.debug"
	arm-none-eabi-readelf -a boot.elf > boot.elf.debug

	@echo "Launching QEMU in paused mode (for GDB attach)"
	qemu-system-arm -S -M $(BOARD) -cpu $(CPU) -nographic -kernel boot.elf -gdb tcp::1234


# 4) Attach GDB
gdb:
	gdb-multiarch -q $(PROJECT).elf -ex "target remote localhost:1234"

# 5) Clean up all build artifacts
clean:
	@echo "Cleaning build artifacts"
	rm -f *.o *.elf *.lst *.debug *.bin *.map $(PROJECT)-clean.s .gdb_history

# 6) Clean only C-to-ASM generated files
clean-asm:
	@echo "Cleaning c-asm.s and c-asm-clean.s"
	rm -f c-asm.s c-asm-clean.s pure-asm.s clean-asm.s
