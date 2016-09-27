//
// led.h
//

#define GRN	0x1
#define RED 0x2


extern void flash_led ( unsigned int time, unsigned int colors, unsigned int reps );
extern void flash_lonum( unsigned int num );
extern void blink_led(unsigned int color);

