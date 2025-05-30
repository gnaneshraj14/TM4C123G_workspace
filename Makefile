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

# Toolchain
AS           := arm-none-eabi-as
CC           := arm-none-eabi-gcc
LD           := arm-none-eabi-ld
OBJCOPY      := arm-none-eabi-objcopy

# OpenOCD
OPENOCD      := openocd
OPENOCD_CFG  := -f tm4c123g.cfg

# Flags
ASFLAGS      := -mthumb -mcpu=$(CPU) -g
CFLAGS       := -mthumb -mcpu=$(CPU) -g -O0 -ffreestanding -nostdlib
LDFLAGS      := -T linker.ld

ELF          := $(PROJECT).elf
BIN          := $(PROJECT).bin

# 1) List all sources and derive object names
SRCS         := boot.S main.c
# First replace .S → .o, then .c → .o
OBJS         := $(SRCS:.S=.o)
OBJS         := $(OBJS:.c=.o)

# 2) Tell make we’ll build .o from .S and .c
.SUFFIXES: .S .c .o .elf .bin

# 3) Assemble only with ASFLAGS
%.o: %.S
	$(AS) $(ASFLAGS) $< -o $@

# 4) Compile C with CC+CFLAGS
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# 5) Link to ELF and produce BIN (both boot.o and main.o)
$(ELF): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@
	$(OBJCOPY) -O binary $@ $(BIN)

# QEMU target
qemu: $(ELF)
	qemu-system-arm \
	  -S -M lm3s6965evb \
	  -cpu $(CPU) \
	  -nographic \
	  -kernel $(ELF) \
	  -gdb tcp::1234

# GDB target
gdb:
	gdb-multiarch -q $(ELF) \
	  -ex "target remote localhost:1234"

# Flash target
flash: $(BIN)
	$(OPENOCD) $(OPENOCD_CFG) \
	  -c "program $(BIN) verify reset exit"

# OpenOCD debug server
debug:
	$(OPENOCD) $(OPENOCD_CFG) &

# Clean up build artifacts
clean:
	rm -f *.o $(ELF) $(BIN) *.lst *.debug .gdb_history

