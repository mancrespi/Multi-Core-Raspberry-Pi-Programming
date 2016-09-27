#include "os.h"
//user application interrupts on svc 0
void	userspace ()
{
	unsigned int now, then;

	then = now_usec();

	while (1) {
		now = now_usec();
		if ((now - then) > (1 * ONE_SEC)) {
			then = now;
			asm("svc #0");
		}
	}
}

