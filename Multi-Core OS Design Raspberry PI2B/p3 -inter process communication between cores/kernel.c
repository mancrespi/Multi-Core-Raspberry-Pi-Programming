#include "hype.h"



void
kernel( unsigned int core )
{
	#include "initf.auto"
	return;
}

extern unsigned int krecv();

void
incoming_kmsg()
{
	unsigned int msg = recv(123); //unused junk value
	int id;

	if (MSG_VALID(msg) && (id = MSG_SENDER(msg)) != 0) {
		msg = MSG_DATA(msg);
		msg += 1;
		send(id, msg);
	}
}

