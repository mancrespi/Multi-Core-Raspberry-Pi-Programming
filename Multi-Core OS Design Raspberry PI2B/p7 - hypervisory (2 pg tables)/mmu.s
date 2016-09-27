
.global readTTBCR
readTTBCR:
	MRC		p15, 0, r0, c2, c0, 2 		@ Read TTBCR into r0 
	bx		lr

.global writeTTBCR
writeTTBCR:
	MCR		p15, 0, r0, c2, c0, 2 		@ Write r0 to TTBCR
	bx		lr


.global readTTBR0
readTTBR0:
	MRC		p15, 0, r0, c2, c0, 0 		@ Read 32-bit TTBR0 into r0
	bx		lr

.global writeTTBR0
writeTTBR0:
	MCR		p15, 0, r0, c2, c0, 0 		@ Write r0 to 32-bit TTBR0
	bx		lr

.global readTTBR1
readTTBR1:
	MRC		p15, 0, r0, c2, c0, 1 		@ Read 32-bit TTBR1 into r0
	bx		lr

.global writeTTBR1
writeTTBR1:
	MCR		p15, 0, r0, c2, c0, 1 		@ Write r0 to 32-bit TTBR1
	bx		lr


.global readCONTEXTIDR
readCONTEXTIDR:
	MRC		p15, 0, r0, c13, c0, 1 		@ Read CONTEXTIDR into Rt
	bx		lr

.global writeCONTEXTIDR
writeCONTEXTIDR:
	MCR		p15, 0, r0, c13, c0, 1 		@ Write Rt to CONTEXTIDR
	bx		lr


.global readDACR
readDACR:
	MRC		p15, 0, r0, c3, c0, 0 		@ Read DACR into Rt 
	bx		lr

.global writeDACR
writeDACR:
	MCR		p15, 0, r0, c3, c0, 0 		@ Write Rt to DACR
	bx		lr


.global readSCTLR
readSCTLR:
	MRC		p15, 0, r0, c1, c0, 0 		@ Read SCTLR into Rt 
	bx		lr

.global writeSCTLR
writeSCTLR:
	MCR		p15, 0, r0, c1, c0, 0 		@ Write Rt to SCTLR
	bx		lr

