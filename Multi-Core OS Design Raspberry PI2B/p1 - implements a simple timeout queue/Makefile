ARMGNU ?= arm-none-eabi

KSIZE = 0x2000

LINKAUTO = memmap.auto
TARGET = kernel7.bin
SDTARGET = /Volumes/boot/kernel7.img
DEPS = *.h

COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding 

all : $(TARGET)

$(LINKAUTO) : memmap Makefile
	cat memmap > $(LINKAUTO)
	perl -i -p0e 's/__SIZE__/$(KSIZE)/g' $(LINKAUTO)

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.auto

cp : $(TARGET)
	cp $(TARGET) $(SDTARGET)

.s.o : 
	$(ARMGNU)-as $< -o $@

.c.o : $(DEPS)
	$(ARMGNU)-gcc $(COPS) -c $< -o $@

OBJECTS := $(patsubst %.s,%.o,$(wildcard *.s)) $(patsubst %.c,%.o,$(wildcard *.c))

$(TARGET) : $(OBJECTS) $(LINKAUTO)
	$(ARMGNU)-ld $(OBJECTS) -T $(LINKAUTO) -o kernel7.elf
	$(ARMGNU)-objdump -D kernel7.elf > kernel7.list
	$(ARMGNU)-objcopy kernel7.elf -O ihex kernel7.hex
	$(ARMGNU)-objcopy kernel7.elf -O binary $(TARGET)
	rm -f $(LINKAUTO)

