#include "hype.h"

void
client1(void)
{
	unsigned int now, inmsg, outmsg, diff;

	while (1) {
		oldwait(50);
		now = now_usec();
		outmsg = now & 0x000FFFFF;

		do {
			unsigned int backoff = 1;
			while (!send(0, outmsg)) {
				oldwait(backoff);
				backoff *= 2;
			}
		} while (( inmsg = recv(USER_TIMEOUT) ) == NACK);
		
		diff = MSG_DATA(inmsg) - outmsg;
		if (diff == 1) {
			blink_led(GRN);
		}
	}
}

void
client2(void)
{
	unsigned int now, inmsg, outmsg, diff;

	while (1) {
		oldwait(50);
		now = now_usec();
		outmsg = now & 0x00FFFFFF;

		do {
			unsigned int backoff = 2;
			while (!send(0, outmsg)) {
				oldwait(backoff);
				backoff *= 2;
			}
		} while (( inmsg = recv(USER_TIMEOUT) ) == NACK);

		diff = MSG_DATA(inmsg) - outmsg;
		if (diff == 1) {
			blink_led(RED);
		}
	}
}
