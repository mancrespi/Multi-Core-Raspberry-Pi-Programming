#include "hype.h"

#define DEBUG 1

void	threadX_blinker ( unsigned int color )
{
	unsigned int now, then, num;

	num = 0;
	then = now_usec();

	while (1) {
		now = now_usec();
		if ((now - then) > (1 * ONE_SEC)) {
			then = now;

			flash_led(1, color, num+1);

			num = (num + 1) & 0x3;
		}
	}
}


void	entry_t1 ()
{
	while (1) {
		threadX_blinker(RED);
		flash_lonum(3);
	}
}

void	entry_t0 ()
{
	while (1) {
		threadX_blinker(GRN);
		flash_lonum(3);
	}
}

