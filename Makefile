# Toolchain variables
# Centralize CC, AS, LD so you can swap compilers or add flags in one place.
# 
# Produce both ELF and BIN
# Generating a .bin via objcopy ensures you’re flashing exactly what you ran under QEMU.
# 
# Consistent target names
# Use PROJECT to derive both ELF and BIN, and make sure your QEMU and GDB lines refer to $(ELF) not $(PROJECT).elf vs boot.elf confusion.
# 
# CFLAGS for debugging
# -g and -O0 make stepping through startup code far easier in GDB.

PROJECT      := boot
CPU          ?= cortex-m4
CC           := arm-none-eabi-gcc
AS           := arm-none-eabi-as
LD           := arm-none-eabi-ld
OBJDUMP      := arm-none-eabi-objdump
READELF      := arm-none-eabi-readelf
OPENOCD      := openocd
OPENOCD_CFG  := -f tm4c123g.cfg

CFLAGS       := -mthumb -mcpu=$(CPU) -g -O0 -ffreestanding -nostdlib
LDFLAGS      := -T linker.ld

# Default ELF basename must match qemu target
ELF          := $(PROJECT).elf
BIN          := $(PROJECT).bin

.SUFFIXES: .S .o .elf .bin

all: $(BIN)

# assemble + compile
%.o: %.S
	$(AS) $(CFLAGS) $< -o $@

# link to ELF
$(ELF): boot.o
	$(LD) $(LDFLAGS) $^ -o $@
	# produce bin
	arm-none-eabi-objcopy -O binary $@ $(BIN)

qemu: $(ELF)
	qemu-system-arm \
	  -S -M lm3s6965evb \
	  -cpu $(CPU) \
	  -nographic \
	  -kernel $(ELF) \
	  -gdb tcp::1234

gdb:
	gdb-multiarch -q $(ELF) \
	  -ex "target remote localhost:1234"

flash: $(BIN)
	$(OPENOCD) $(OPENOCD_CFG) \
	  -c "program $(BIN) verify reset exit"

debug:
	$(OPENOCD) $(OPENOCD_CFG) &

clean:
	rm -f *.o $(ELF) $(BIN) *.lst *.debug .gdb_history
