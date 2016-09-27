.globl _start
_start:
    b reset
    b hang
    b hang
    b hang
    b hang
    b hang
    b irq_nop
    b hang


.equ	USR_mode,	0x10
.equ	FIQ_mode,	0x11
.equ	IRQ_mode,	0x12
.equ	SVC_mode,	0x13
.equ	HYP_mode,	0x1A
.equ	SYS_mode,	0x1F
.equ	No_Int,		0xC0


.include "stacks.auto"


reset:

	mrc p15, 0, r0, c1, c0, 0 @ Read System Control Register
@	orr r0, r0, #(1<<2)       @ dcache enable
	orr r0, r0, #(1<<12)      @ icache enable
	and r0, r0, #0xFFFFDFFF   @ turn on vector table at 0x0000000 (bit 12)
	mcr p15, 0, r0, c1, c0, 0 @ Write System Control Register

@ check core ID
.globl do_over
do_over:
	mrc     p15, 0, r0, c0, c0, 5
	ubfx    r0, r0, #0, #2
	cmp     r0, #0					@ is it core 0?
	beq     core0

	@ it is not core0, so do things that are appropriate for SVC level as opposed to HYP
	@ eg., turn on virtual memory, etc.

	@ set up separate stacks for each core
	mrc     p15, 0, r0, c0, c0, 5
	ubfx    r0, r0, #0, #2
	cmp     r0, #1					@ is it core 1?
	beq     core1
	cmp     r0, #2					@ is it core 2?
	beq     hang
	cmp     r0, #3					@ is it core 3?
	beq     hang

	@ CPU ID is not 0..3 - wtf
	b hang

core1:
	mov 	r2, # No_Int | IRQ_mode
	msr		cpsr_c, r2
	mov		sp, # IRQSTACK1
	mov 	r2, # No_Int | FIQ_mode
	msr		cpsr_c, r2
	mov		sp, # FIQSTACK1
	mov 	r2, # No_Int | SVC_mode
	msr		cpsr_c, r2
	mov		sp, # KSTACK1

@	mov 	r2, # USR_mode
	mov 	r2, # SYS_mode
	msr		cpsr_c, r2

	bl		enable_irq

	mov		sp, # USTACK1
	mov 	r2,#0
	str 	r2,threadx
	str 	r2,start_t1
t0:	bl		entry_t0
t1:	bl 		entry_t1
	b hang

hang: b hang

core0:
	mov 	r2, # No_Int | IRQ_mode
	msr		cpsr_c, r2
	mov		sp, # IRQSTACK0

	mov 	r2, # No_Int | FIQ_mode
	msr		cpsr_c, r2
	mov		sp, # FIQSTACK0

	mov 	r2, # No_Int | HYP_mode
	msr		cpsr_c, r2
	mov		sp, # KSTACK0

	bl		kernel
	b hang

			.word 0
			.word 0
threadsave:	.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0

			.word 0
			.word 0
t1_save:	.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0
			.word 0


save_r13_irq: .word 0
save_r13_irq1: .word 0

save_r14_irq: .word 0

.globl threadx
threadx: 	.word 0

.globl start_t1
start_t1:	.word 0

badval:	.word	0xdeadbeef


@
@ based on code from rpi discussion boards
@
irq_nop:
	
	str		r13, save_r13_irq			@ save the IRQ stack pointer

	push 	{r0}
	ldr		r0, threadx
	cmp 	r0, #0
	pop		{r0}

	beq 	ts
	ldr 	r13, =t1_save
	b 		store

ts:	
	ldr 	r13, =threadsave			@ load the IRQ stack pointer with address of TCB

store:	
	add		r13, r13, #56				@ jump to middle of TCB for store up and store down
	stmia	sp, {sp, lr}^				@ store the USR stack pointer & link register, upwards
	push	{r0-r12, lr}				@ store USR regs 0-12 and IRQ link register (r14), downwards

	@ regs saved, we can now destroy stuff
	mov r0, #1
	bl	clear_interrupt

	@ check to see if thread has already started
	ldr		r2, start_t1
	cmp		r2, #1
	beq		ld

	@------------------------------------------------------------------------------------
	mov 	r2, # SYS_mode
	msr		cpsr_c, r2

	mov 	r2, #1
	str 	r2, start_t1
	str 	r2, threadx
	mov		sp, # USTACK2
	b 		t1
	@------------------------------------------------------------------------------------

    @ now check to see which contex to load (swap)
ld:	ldr		r0, threadx
	eor		r0,r0, #1
	str 	r0, threadx

restore:
	ldr 	r0, threadx
	cmp		r0, #0

    @ load the IRQ stack pointer with address of TCB
	beq		td  
	ldr 	r13, =t1_save
	b 		dn

td:	ldr 	r13, =threadsave

dn: pop		{r0-r12, lr}			@ load USR regs 0-12 and IRQ link register (r14), upwards
	ldmia	sp, {sp, lr}^			@ load the USR stack pointer & link register, upwards
	nop								@ evidently it's a god idea to put a NOP after a LDMIA
	

s0:	ldr		r13, save_r13_irq			@ restore the IRQ stack pointer from way above
	subs	pc, lr, #4					@ return from exception

