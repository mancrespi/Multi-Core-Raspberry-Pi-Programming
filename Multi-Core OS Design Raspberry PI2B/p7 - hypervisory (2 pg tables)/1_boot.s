.globl _start
_start:
    ldr pc,res_handler          @ RESET                 runs in SVC mode
    ldr pc,und_handler          @ UNDEF INSTR           runs in UND mode
    ldr pc,swi_handler          @ SWI (TRAP)            runs in SVC mode
    ldr pc,pre_handler          @ PREFETCH ABORT        runs in ABT mode
    ldr pc,dat_handler          @ DATA ABORT            runs in ABT mode
    ldr pc,hyp_handler          @ HYP MODE              runs in HYP mode
    ldr pc,irq_handler          @ IRQ INTERRUPT         runs in IRQ mode
    ldr pc,fiq_handler          @ FIQ INTERRUPT         runs in FIQ mode
res_handler:            .word reset
und_handler:            .word hang
swi_handler:            .word blinky
pre_handler:            .word hang
dat_handler:            .word hang
hyp_handler:            .word hang
irq_handler:            .word irq_nop
fiq_handler:            .word hang


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

	bl		enable_irq

	mov 	r2, # USR_mode
	msr		cpsr_c, r2

	mov		sp, # USTACK1
	mov 	r0, #1
	@bl 	userspace
	bl 		blinky
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

.equ    T_bit,   0x20                @ Thumb bit (5) of CPSR/SPSR.
blinky:
    STMFD   sp!, {r0-r3, r12, lr}  @ Store registers
    MOV     r1, sp                 @ Set pointer to parameters
    MRS     r0, spsr               @ Get spsr
    STMFD   sp!, {r0, r3}          @ Store spsr onto stack and another
                                   @ register to maintain 8-byte-aligned stack
    TST     r0, #T_bit             @ Occurred in Thumb state?
    LDRNEH  r0, [lr,#-2]           @ Yes: Load halfword and...
    BICNE   r0, r0, #0xFF00        @ ...extract comment field
    LDREQ   r0, [lr,#-4]           @ No: Load word and...
    BICEQ   r0, r0, #0xFF000000    @ ...extract comment field

    @ r0 now contains SVC number
    @ r1 now contains pointer to stacked registers

    BL      flash_lonum            @ Call main part of handler

    LDMFD   sp!, {r0, r3}          @ Get spsr from stack
    MSR     SPSR_cxsf, r0          @ Restore spsr
    LDMFD   sp!, {r0-r3, r12, pc}^ @ Restore registers and return

irq_nop:
	push	{r0, lr}				@ save regs
	bl 		enable_vm
	mov 	r0, #1
	bl		clear_interrupt
	pop		{r0, lr}				@ restore regs
	subs	pc, lr, #4				@ return from exception

