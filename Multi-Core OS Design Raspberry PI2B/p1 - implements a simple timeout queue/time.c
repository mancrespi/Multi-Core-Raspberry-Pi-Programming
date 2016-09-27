// Emanuelle Crespi
// ENEE447: time library
// UID: 111556427

#include "time.h"
#include "os.h"

#define PRESCL 0x001FEFFF //2093055

unsigned int
gettime( )
{
	unsigned int time;
	time = GET32(0x4000001C);
	return time;
}

unsigned int
timediff( unsigned int now, unsigned int then )
{
	unsigned int diff;
	diff = now - then;
	return diff;
}

void
wait( unsigned int time )
{
	//Core timer runs from the APB clock
	PUT32(0x40000000,1<<8);	

	PUT32(0x40000008,PRESCL);  //set prescalar (divider)

	//initial state of timer
	unsigned int strt = GET32(0x4000001C);	

	while(1){
		//current state of timer (ABP)
		unsigned int now = GET32(0x4000001C); 
		
		//LS32 of control reg- past time
		unsigned int diff = timediff( now, strt );

		//stop waiting after one second
		if(diff >= time || diff == strt) break;
	}
}

