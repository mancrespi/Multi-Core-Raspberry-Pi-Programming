#include "hype.h"

unsigned int
ukernel_status(unsigned int id)
{
	unsigned int inmsg, outmsg, status/*, thread*/;
	outmsg = SET_REGMSG( CORE_RUN, id, 0xcafe );

	do {
		unsigned int backoff = 1;
		while (!send(0, outmsg)) {
			oldwait(backoff);
			backoff *= 2;			
		}
			/*blink_led(RED);*/
	} while (( inmsg = recv(USER_TIMEOUT) ) == NACK);
	//
	// do whatever the kernel says to do:
	//
	// CORE_RESTART -- only in error situations (optional extra credit)
	// CORE_RUN -- specific thread number
	// 
	status = REGMSG_STATUS(inmsg);
	/*thread = REGMSG_THREAD(inmsg);*/
	/*if ( status == CORE_RUN ){*/
	return REGMSG_THREAD( inmsg );
	/*}*/

}
