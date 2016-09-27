/*
 * hype.h
 */

typedef void (* pfv_t)();
typedef int (* pfi_t)();
typedef unsigned int (* pfu_t)();

#define NULL 0

#define NUM_CORES	4
#define MAX_THREADS	16

//
// this is how approximate our timing is ... :)
//
#define	ONE_USEC	0x1
#define	ONE_MSEC	(0x1 << 10)
#define	ONE_SEC		(0x1 << 20)

#define	USEC(u)		(u * ONE_USEC)
#define	MSEC(m)		(m * ONE_MSEC)
#define	SEC(s)		(s * ONE_SEC)		// note we can only go up to 2000 seconds

#define MAX_SLEEP_INTERVAL	USEC( 100 )
#define MIN_SLEEP_INTERVAL	USEC( 4 )

#define	USER_TIMEOUT	ONE_SEC
#define	KERN_TIMEOUT	0
#define	MIN_TIMEOUT		USEC(2)


//
// time/timeoutq routines
//

extern unsigned int usec_diff( unsigned int now, unsigned int then );	// only good for short deltas: assumes only one wrap-around is possible
extern unsigned int now_usec( void );
extern unsigned int now_hrs( void );
extern void get_time ( unsigned int *sec, unsigned int *usec);
extern void wait ( unsigned int );
extern void oldwait ( unsigned int );

extern void create_timeoutq_event(int start_time, int repeat_interval, pfv_t gofunction, unsigned int data, unsigned int priority);
// gofunction:	void function( unsigned int data, unsigned int priority );



//
// IPC primitives
//

extern unsigned int send( unsigned int dest, unsigned int msg );
extern unsigned int recv( unsigned int timeout );

#define	MSG_VALID(m)	(m & 0x80000000)
#define	MSG_SENDER(m)	((m >> 28) & 0x03)
#define	MSG_DATA(m)		(m & 0x0FFFFFFF)

#define	NACK	0



//
// errno/debug routines
//

extern void blink_led( unsigned int );
extern void flash_cpuid( );
extern void flash_lonum( unsigned int );
#define GRN 0x1
#define RED 0x2
extern void flash_led ( unsigned int, unsigned int, unsigned int );
extern void flash_led_diffio ( unsigned int, unsigned int, unsigned int );


//
// utilities/etc (assembly-code routines)
//
extern void PUT32 ( unsigned int, unsigned int );
extern unsigned int GET32 ( unsigned int );
extern unsigned int GETPC ( void );
extern void dummy ( unsigned int );
extern unsigned int BRANCHTO ( unsigned int );
extern unsigned int cpu_id ( void );
extern void idle ( void );


//
// VM routines
//

extern unsigned int readTTBCR();
extern void writeTTBCR(unsigned int);
extern unsigned int readTTBR0();
extern void writeTTBR0(unsigned int);
extern unsigned int readTTBR1();
extern void writeTTBR1(unsigned int);
extern unsigned int readCONTEXTIDR();
extern void writeCONTEXTIDR(unsigned int);
extern unsigned int readDACR();
extern void writeDACR(unsigned int);
extern unsigned int readSCTLR();
extern void writeSCTLR(unsigned int);

