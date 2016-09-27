
extern void PUT32 ( unsigned int, unsigned int );
extern unsigned int GET32 ( unsigned int );
extern void dummy ( unsigned int );
extern void idle ( void );

#define	CLOCK_CTL		0x40000000
#define	CLOCK_BY_1		0
#define	CLOCK_BY_2		(0x1 << 9)
#define	CLOCK_APB		(0x1 << 8)
#define	CLOCK_CRYSTAL	0

#define	CLOCK_HI	0x40000020
#define	CLOCK_LO	0x4000001C

#define	TIMER_CTL	0x40000034
#define	TIMER_IRQ	0x40000038
#define	TIMER_ROUTE	0x40000024

#define	CORE_TIMER_INT0	0x40000040
#define	CORE_TIMER_INT1	0x40000044
#define	CORE_TIMER_INT2	0x40000048
#define	CORE_TIMER_INT3	0x4000004C
#define	CORE_TIMER_NOINT	0
#define	CORE_TIMER_IRQ0	(0x1)
#define	CORE_TIMER_IRQ1	(0x1 << 1)
#define	CORE_TIMER_IRQ2	(0x1 << 2)
#define	CORE_TIMER_IRQ3	(0x1 << 3)
#define	CORE_TIMER_FIQ0	(0x1 << 4)
#define	CORE_TIMER_FIQ1	(0x1 << 5)
#define	CORE_TIMER_FIQ2	(0x1 << 6)
#define	CORE_TIMER_FIQ3	(0x1 << 7)

#define TIMER_IRQ_TO_CORE0	0

#define IRQ_CLEAR		0x80000000
#define IRQ_RELOAD		0x40000000
#define IRQ_NORELOAD	0

#define	CTL_INTERRUPT	0x20000000
#define	CTL_NOINTERRUPT	0
#define	CTL_ENABLE		0x10000000
#define	CTL_DISABLE		0
#define	CTL_TIMEMASK	0x0FFFFFFF


void
get_time( unsigned int *hrs, unsigned int *usec )
{
	unsigned int hi, lo;

	lo = GET32(CLOCK_LO);
	hi = GET32(CLOCK_HI);

	if (hrs) *hrs = hi;
	if (usec) *usec = lo;

	return;
}

unsigned int
now_usec () 
{
	return GET32(CLOCK_LO);
}

unsigned int
now_hrs () 
{
	return GET32(CLOCK_HI);
}

void
clear_timer_interrupts()
{
	PUT32( TIMER_CTL, CTL_NOINTERRUPT | CTL_DISABLE | (CTL_TIMEMASK - 1) );	// reset timer to the max time possible
	PUT32( TIMER_IRQ, IRQ_CLEAR | IRQ_NORELOAD );
	return;
}

//
// note this only is set up for Core-0
// the other cores need to do their own thing for now
// (like use "oldwait")
void
wait ( unsigned int time )
{
	unsigned int ctl_value;

	time *= 38;	// adjust for difference between main clock and countdown timer

	ctl_value = CTL_INTERRUPT | CTL_ENABLE | (time & CTL_TIMEMASK);

	PUT32( TIMER_CTL, ctl_value );

	idle();		// calls a wfi instruction

	clear_timer_interrupts();

	return;
}

#if 1
void
oldwait ( unsigned int beats )
{
	unsigned int i;
	for (i=0; i<0x80000 * beats; i++) {
		dummy(beats);
	}
	return;
}
#endif

unsigned int
usec_diff( unsigned int now, unsigned int then )
{
	// allows rollover but assumes that less than an hour has passed ... only acceptable if we keep it local
	if (now < then) {
		return now + ((unsigned int)0xFFFFFFFF - then);
	} else {
		return now - then;
	}
}


#define INT_IRQ	0x0F
#define INT_FIQ	0xF0
#define INT_NONE 0

void _init_time()
{
	// timers & interrupts

	PUT32( CLOCK_CTL, CLOCK_BY_1 | CLOCK_CRYSTAL);
	PUT32( TIMER_ROUTE, TIMER_IRQ_TO_CORE0);

	PUT32(CORE_TIMER_INT0, CORE_TIMER_NOINT);
	PUT32(CORE_TIMER_INT1, CORE_TIMER_NOINT);
	PUT32(CORE_TIMER_INT2, CORE_TIMER_NOINT);
	PUT32(CORE_TIMER_INT3, CORE_TIMER_NOINT);

}

