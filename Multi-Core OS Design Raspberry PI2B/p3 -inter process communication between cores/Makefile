ARMGNU ?= arm-none-eabi

DEBUG = 1

KSIZE =		0x2000
HEAPSIZE =	0x30000
FIQSTACK =	0x2000
IRQSTACK =	0x2000
KSTACK =	0x2000
USTACK =	0x2000

LINK = memmap.auto
INIT = initf.auto
STACKS = stacks.auto
TARGET = kernel7.bin
SDTARGET = /Volumes/boot/kernel7.img
DEPS = *.h

COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding 

all : $(TARGET)

$(LINK) : memmap Makefile
	cat memmap > $(LINK)
	perl -i -p0e 's/__SIZE__/$(KSIZE)/g' $(LINK)

$(INIT) : *.c  Makefile
	grep _init *.c | awk '{ print "extern void ", $$2, ";" }' > $(INIT)
	grep _init *.c | awk '{ print $$2 , ";" }' >> $(INIT)

F_START = 	$$(($(KSIZE)+$(FIQSTACK)))
I_START = 	$$(($(F_START)+(3*$(FIQSTACK))+$(IRQSTACK)))
K_START =	$$(($(I_START)+(3*$(IRQSTACK))+$(KSTACK)))
U_START =	$$(($(K_START)+(3*$(KSTACK))+$(USTACK)))

$(STACKS) : Makefile
	cat < /dev/null > $(STACKS)
	for i in 3 2 1 0 ; do \
	echo ".equ	FIQSTACK$$i , $$(($(F_START)+$(FIQSTACK)*$$i))" >> $(STACKS) ;\
	echo ".equ	IRQSTACK$$i , $$(($(I_START)+$(IRQSTACK)*$$i))" >> $(STACKS) ;\
	echo ".equ	KSTACK$$i   , $$(($(K_START)+$(KSTACK)*$$i))" >> $(STACKS) ;\
	echo ".equ	USTACK$$i   , $$(($(U_START)+$(USTACK)*$$i))" >> $(STACKS) ;\
	done
	echo ".globl heapstart" >> $(STACKS)
	echo "heapstart: .word $$(($(KSIZE)+(4*$(FIQSTACK))+(4*$(IRQSTACK))+(4*$(KSTACK))+(4*$(USTACK))))" >> $(STACKS)

clean :
	rm -f *.o
	rm -f *.bin
	rm -f *.hex
	rm -f *.elf
	rm -f *.list
	rm -f *.img
	rm -f *.auto

cp : clean $(TARGET)
	cp $(TARGET) $(SDTARGET)

.s.o : 
	$(ARMGNU)-as $< -o $@

.c.o : $(DEPS)
	$(ARMGNU)-gcc $(COPS) -c $< -o $@

OBJECTS := $(patsubst %.s,%.o,$(wildcard *.s)) $(patsubst %.c,%.o,$(wildcard *.c))

$(TARGET) : $(STACKS) $(INIT) $(OBJECTS) $(LINK)
	$(ARMGNU)-ld $(OBJECTS) -T $(LINK) -o kernel7.elf
	$(ARMGNU)-objdump -D kernel7.elf > kernel7.list
	$(ARMGNU)-objcopy kernel7.elf -O ihex kernel7.hex
	$(ARMGNU)-objcopy kernel7.elf -O binary $(TARGET)
	rm -f $(LINK)

