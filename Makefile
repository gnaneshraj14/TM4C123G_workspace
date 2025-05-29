PROJECT=boot
CPU ?= cortex-m4
OPENOCD = openocd
OPENOCD_CFG = -f tm4c123g.cfg

qemu:
	arm-none-eabi-as -mthumb -mcpu=$(CPU) -ggdb -c boot.S -o boot.o
	arm-none-eabi-ld -Tlinker.ld boot.o -o boot.elf
	arm-none-eabi-objdump -D -S boot.elf > boot.elf.lst
	arm-none-eabi-readelf -a boot.elf > boot.elf.debug
	qemu-system-arm -S -M lm3s6965evb -cpu $(CPU) -nographic -kernel $(PROJECT).elf -gdb tcp::1234

gdb:
	gdb-multiarch -q $(PROJECT).elf -ex "target remote localhost:1234"

flash: $(PROJECT).bin
    $(OPENOCD) $(OPENOCD_CFG) -c "program $< verify reset exit"

debug:
    $(OPENOCD) $(OPENOCD_CFG) &

clean:
	rm -rf *.out *.elf .gdb_history *.lst *.debug *.o