#include "hype.h"

#define DEBUG 1
unsigned char c1_st[50] = "C1:Start...";
unsigned char c1_int_rec[50] = "C1:Int Rcvd...";

void	two_io_locations ( )
{
	unsigned int now, then;

        oldwait(1);

	then = now_usec();
    print_text(c1_st);

	while (1) {
		now = now_usec();
		if ((now - then) > MSEC(5)) {
			then = now;

			flash_led(1, RED, 4);
			flash_led_diffio(1, GRN, 4);

		}
	}
}

void interrupt_recvd() {
  print_text(c1_int_rec);
}

