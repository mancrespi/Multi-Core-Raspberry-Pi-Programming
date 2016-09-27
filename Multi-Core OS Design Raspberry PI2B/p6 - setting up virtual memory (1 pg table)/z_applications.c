#include "hype.h"

#define DEBUG 1

void	two_io_locations ( )
{
	unsigned int now, then;

	then = now_usec();

	while (1) {
		now = now_usec();
		if ((now - then) > MSEC(500)) {
			then = now;

			flash_led(1, RED, 4);
			flash_led_diffio(1, GRN, 4);
		}
	}
}

