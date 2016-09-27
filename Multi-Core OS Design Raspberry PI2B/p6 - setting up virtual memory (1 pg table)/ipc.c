/*
 * IPC
 */

#include "hype.h"

/* set bits - write-only */
#define INT_SET_BASE			0x40000080
/* clear bits - read/write */
#define INT_CLR_BASE			0x400000C0

/*
** these interrupt through MAILBOX ONE, not mailbox zero
*/
void
interrupt_core( unsigned int core )
{
	PUT32(INT_SET_BASE + ((core & 0x3) << 4) + 4, 0x1);
}

void
clear_interrupt( unsigned int core )
{
	PUT32(INT_CLR_BASE + ((core & 0x3) << 4) + 4, 0xFFFFFFFF);
}


void _init_ipc()
{
	unsigned int i;

	for (i=0; i<NUM_CORES; i++) {
		// clear the mailbox
	}

	#define INT_IRQ	0x0E
	#define INT_FIQ	0xF0
	#define INT_NONE 0

	// mailboxes & interrupts
	PUT32(0x40000050, INT_NONE);
	PUT32(0x40000054, INT_IRQ);		// mboxes 1..3 interrupt via IRQ
	PUT32(0x40000058, INT_IRQ);
	PUT32(0x4000005C, INT_IRQ);

	return;
}

