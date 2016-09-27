//
// hello, world!!!
//

#include "time.h"
#include "led.h"


void
notmain()
{
	unsigned int now, then, delta;
	while (1) {
		wait( ONE_SECOND );
		then = gettime();
		blink_led( GRN );
		now = gettime();
		delta = timediff( now, then );
	}
}
