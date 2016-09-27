#include "hype.h"

extern unsigned int interrupt_core( unsigned int );

void
kernel()
{
	unsigned int then, now, delta;

	#include "initf.auto"

	then = now_usec();
	while (1) {
		now = now_usec();
		delta = usec_diff( now, then );
		if (delta > 5 * ONE_SEC) {
			then = now;
			interrupt_core(1);
			while (1) continue;
		}
	}
}

