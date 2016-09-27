//
// time.h
//
// information regarding the time library
//

#define	ONE_SECOND	0x0002F10		//12048


extern unsigned int gettime( void );
extern unsigned int timediff( unsigned int now, unsigned int then );
extern void wait( unsigned int time );

