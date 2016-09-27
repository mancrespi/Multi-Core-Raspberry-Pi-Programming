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
		if (delta > 4 * ONE_SEC) {
			then = now;
			interrupt_core(1);
			interrupt_core(2);
		}
	}
}

extern unsigned int krecv();

void
incoming_kmsg()
{
	unsigned int msg = krecv();
	int id, thread;
	int swap = now_usec() & 2;

	if ( msg && (id = MSG_SENDER(msg)) != 0) {
		msg = MSG_DATA(msg);

		if (REGMSG_STATUS(msg) == CORE_RUN) {
			thread = REGMSG_THREAD(msg);
			if (swap) {
				if (thread & 0x1) {
					thread &= 0xfffffffe;
				} else {
					thread |= 0x1;
				}
			}
			msg = SET_REGMSG( CORE_RUN, thread, 0 );
		} else {
			msg = SET_REGMSG( CORE_RESET, 0, 0 );
		}
		send(id, msg);
	}
}

