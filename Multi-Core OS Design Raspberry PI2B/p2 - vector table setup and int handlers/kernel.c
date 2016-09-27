#include "os.h"


#define INT_IRQ	0x0F
#define INT_FIQ	0xF0
#define INT_NONE 0

/* set bits - write-only */
#define INT_SET_BASE			0x40000080
/* clear bits - read/write */
#define INT_CLR_BASE			0x400000C0

void
interrupt_core( unsigned int core )
{
	PUT32(INT_SET_BASE + ((core & 0xf) << 4), 0x1);
}

void
clear_interrupt( unsigned int core )
{
	PUT32(INT_CLR_BASE + ((core & 0xf) << 4), 0xFFFFFFFF);
}

extern void _init_time();

void
kernel()
{
	unsigned int then, now, delta;
	PUT32(0x40000054, INT_IRQ);		// mboxes 1..3 *do* interrupt, via IRQ
	PUT32(0x40000058, INT_IRQ);
	PUT32(0x4000005C, INT_IRQ);

	flash_lonum(3);				//blink green/red indicates kernel init status

	then = now_usec();
	while (1) {
		now = now_usec();
		delta = usec_diff( now, then );
		if (delta > ONE_SEC) {
//		if (delta > ((7 * ONE_SEC) + (500 * ONE_MSEC))) {
			then = now;
//			flash_lonum(3);
//			oldwait(20);
			interrupt_core(1);
//			while (1) continue;
		}
	}
}
