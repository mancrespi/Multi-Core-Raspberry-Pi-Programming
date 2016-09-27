@----------------------------------------------------------------------------

.globl _start
_start:
@ jump table:
  b reset  				@ RESET handler   - runs in SVC mode
  b hang  				@ UNDEFINED INSTR handler - runs in UND mode
  b hang			  	@ SWI (TRAP) handler - runs in SVC mode
  b hang  				@ PREFETCH ABORT handler - runs in ABT mode
  b hang  				@ DATA ABORT handler - runs in ABT mode
  b hang  				@ HYP MODE handler - runs in HYP mode
  b IRQ_Handler 		@ IRQ INTERRUPT handler - runs in IRQ mode
  b FIQ_Handler 		@ FIQ INTERRUPT handle - runs in FIQ mode

@----------------------------------------------------------------------------
	.globl thread0					   @ Keep track of current running threads
thread0: .word 0
	.globl thread1
thread1: .word 0
	.globl thread2
thread2: .word 0
	.globl thread3
thread3: .word 0

	.globl t1_begin					   @ Sets when t1 or t3 has begun
t1_begin: .word 0
	.globl t3_begin
t3_begin: .word 0
@----------------------------------------------------------------------------
.equ	USR_mode,	0x10
.equ	FIQ_mode,	0x11
.equ	IRQ_mode,	0x12
.equ	SVC_mode,	0x13
.equ	HYP_mode,	0x1A
.equ	SYS_mode,	0x1F
.equ	No_Int,		0xC0
.globl 	Thd0
.globl 	Thd2
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
	beq     core2					
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

	mov 	r2, # SYS_mode
	msr		cpsr_c, r2

	bl		enable_irq
Thd0:	
	mov		sp, # USTACK1
	mov 	r2, #1
	str 	r2, thread0
	bl		entry_t0
	b hang

core2:
	mov 	r2, # No_Int | IRQ_mode
	msr		cpsr_c, r2
	mov		sp, # IRQSTACK2
	mov 	r2, # No_Int | FIQ_mode
	msr		cpsr_c, r2
	mov		sp, # FIQSTACK2
	mov 	r2, # No_Int | SVC_mode
	msr		cpsr_c, r2
	mov		sp, # KSTACK2

	mov 	r2, # SYS_mode
	msr		cpsr_c, r2

	bl		enable_irq
Thd2:
	mov 	r2, #1
	str 	r2, thread2	
	mov		sp, # USTACK2
	bl		entry_t2

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

	bl		enable_fiq
	bl		kernel
	b hang
@----------------------------------------------------------------------------
			.word 0
			.word 0
t0_save:	.word 0
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

			.word 0
			.word 0
t2_save:	.word 0
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
t3_save:	.word 0
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
@----------------------------------------------------------------------------
save_r13_irq: .word 0
save_r14_irq: .word 0
@----------------------------------------------------------------------------
FIQ_Handler:
    push {r0-r7,lr}
    bl  incoming_kmsg		
    pop {r0-r7,lr}
    subs pc, lr, #4
@----------------------------------------------------------------------------
IRQ_Handler:
	str  r14, save_r14_irq
	str  r13, save_r13_irq
 
save_context:				@ core 1 or core 2?
	bl 		cpu_id
	cmp		r0, #1
	beq		t0
	cmp     r0, #2
	beq		t2
							@ save the thread context (depends on which core)
t1:	ldr 	r13, =t1_save	@ only gets here when thread0 is off 
	ldr		r1, thread1
	cmp 	r1, #1
	beq 	store	
t0:	ldr 	r13, =t0_save	@ core 1 would have made it here
	ldr		r1, thread0
	cmp 	r1, #1
	beq 	store
	b 		t1

t3:	ldr 	r13, =t3_save	@ only gets here when thread2 is off 
	ldr		r1, thread3
	cmp 	r1, #1
	beq 	store	
t2:	ldr 	r13, =t2_save	@ core 2 would have made it here
	ldr		r1, thread2
	cmp 	r1, #1
	beq 	store
	b 		t3

store:	
	add		r13, r13, #56	@ jump to middle of TCB for store up and store down
	stmia	sp, {sp, lr}^	@ store the USR stack pointer & link register, upwards
	push	{r0-r12, lr}	@ store USR regs 0-12 and IRQ link register (r14), downwards
	
	@bl 	 cpu_id
	@bl   clear_interrupt
    bl 	 ukernel_status

load_context:
	cmp 	r0, #0
	beq 	load_t0
	cmp		r0, #1
	beq		load_t1
	cmp     r0, #2
	beq		load_t2
	cmp		r0, #3
	beq		load_t3

load_t0:	
	ldr 	r13, =t0_save
	mov 	r1, #0
	str 	r1, thread1
	mov 	r1, #1
	str     r1, thread0
	b 		dn

load_t1:	
	ldr 	r13, =t1_save
	ldr 	r1, t1_begin
	cmp		r1, #0
	beq		t1_start
	mov 	r1, #0
	str 	r1, thread0
	mov 	r1, #1
	str     r1, thread1
	b 		dn

load_t2:	
	ldr 	r13, =t2_save
	mov 	r1, #0
	str 	r1, thread3
	mov 	r1, #1
	str     r1, thread2
	b 		dn

load_t3:
	ldr 	r13, =t3_save
	ldr 	r1, t3_begin
	cmp		r1, #0
	beq		t3_start
	mov 	r1, #0
	str 	r1, thread2
	mov 	r1, #1
	str     r1, thread3
dn: 
	pop		{r0-r12, lr}			@ load USR regs 0-12 and IRQ link register (r14), upwards
	ldmia	sp, {sp, lr}^			@ load the USR stack pointer & link register, upwards
	nop								@ evidently it's a god idea to put a NOP after a LDMIA

	ldr     r13, save_r13_irq
    ldr     r14, save_r14_irq
    subs pc, lr, #4
@----------------------------------------------------------------------------
t3_start:
	mov 	r2, # SYS_mode
	msr		cpsr_c, r2
	mov		sp, # USTACK3
	mov 	r2, #1
	str 	r2, t3_begin
	mov 	r1, #0
	str 	r1, thread2
	mov 	r1, #1
	str     r1, thread3
	bl 		entry_t3
	b hang

t1_start:
	mov 	r2, # SYS_mode
	msr		cpsr_c, r2
	mov		sp, # USTACK1
	mov 	r2, #1
	str 	r2, t1_begin
	mov 	r1, #0
	str 	r1, thread0
	mov 	r1, #1
	str     r1, thread1
	bl 		entry_t2
	b hang
