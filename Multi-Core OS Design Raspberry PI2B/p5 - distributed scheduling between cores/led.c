
#include "hype.h"

#define GPFSEL3 0x3F20000C
#define GPFSEL4 0x3F200010
#define GPSET1  0x3F200020
#define GPCLR1  0x3F20002C


//-------------------------------------------------------------------------
void
flash_led ( unsigned int time, unsigned int colors, unsigned int reps )
{
	int i;
    unsigned int ra;

	ra=GET32(GPFSEL4);
	ra&=~(7<<21);
	ra|=1<<21;
	PUT32(GPFSEL4,ra);

	ra=GET32(GPFSEL3);
	ra&=~(7<<15);
	ra|=1<<15;
	PUT32(GPFSEL3,ra);

	PUT32(GPCLR1,1<<(35-32));
	PUT32(GPCLR1,1<<(47-32));

    while(reps--)
    {
		if (colors & GRN) PUT32(GPSET1,1<<(47-32));
		if (colors & RED) PUT32(GPSET1,1<<(35-32));
		for (i=0; i<0xA0000 * time; i++) {
			dummy(time);
		}
		if (colors & GRN) PUT32(GPCLR1,1<<(47-32));
		if (colors & RED) PUT32(GPCLR1,1<<(35-32));
		for (i=0; i<0xA0000 * time; i++) {
			dummy(time);
		}
    }

	PUT32(GPCLR1,1<<(35-32));
	PUT32(GPCLR1,1<<(47-32));

    return;
}

void
flash_lonum( unsigned int num )
{
	if (num == 0) {
		flash_led(1, GRN, 2);
		flash_led(1, RED, 2);
	} else if (num == 1) {
		flash_led(1, GRN, 4);
	} else if (num == 2) {
		flash_led(1, RED, 4);
	} else if (num == 3) {
		flash_led(1, RED | GRN, 4);
	} else {
		flash_led(3, RED | GRN, 100);
	}
}

void
blink_led(unsigned int color)
{
	flash_led( 1, color, 1 );
	return;
}

void _init_led()
{
	flash_lonum(3);
}
