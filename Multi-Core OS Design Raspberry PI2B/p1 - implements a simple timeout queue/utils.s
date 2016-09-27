
;@-------------------------------------------------------------------------
;@-------------------------------------------------------------------------

.globl PUT32
PUT32:
    str r1,[r0]
    bx lr

.globl GET32
GET32:
    ldr r0,[r0]
    bx lr

.globl dummy
dummy:
    bx lr

.globl GETPC
GETPC:
    mov r0,lr
    bx lr


.globl cpu_id
cpu_id:
// Return CPU ID (0..3) Of The CPU Executed On
	mrc p15,0,r0,c0,c0,5	// R0 = Multiprocessor Affinity Register (MPIDR)
	ubfx    r0, r0, #0, #2
	bx lr


.globl enable_irq
enable_irq:
    mrs r0,cpsr
    bic r0,r0,#0x80
    msr cpsr_c,r0
    bx lr

.globl enable_fiq
enable_fiq:
    mrs r0,cpsr
    bic r0,r0,#0x40
    msr cpsr_c,r0
    bx lr

.globl disable_irq
disable_irq:
    mrs r0,cpsr
    orr r0,r0,#0x80
    msr cpsr_c,r0
    bx lr

.globl disable_fiq
disable_fiq:
    mrs r0,cpsr
    orr r0,r0,#0x40
    msr cpsr_c,r0
    bx lr


.globl idle
idle:
	wfi
	bx lr




.globl BRANCHTO
BRANCHTO:
    bx r0


;@-------------------------------------------------------------------------
;@-------------------------------------------------------------------------


;@-------------------------------------------------------------------------
;@
;@ Copyright (c) 2012 David Welch dwelch@dwelch.com
;@
;@ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
;@
;@ The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
;@
;@ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;@
;@-------------------------------------------------------------------------
