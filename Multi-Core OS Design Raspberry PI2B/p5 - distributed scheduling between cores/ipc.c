/*
 * IPC
 */

#include "hype.h"


#define	VALIDBIT	0x80000000
#define	IDMASK		0x30000000
#define	MSGBITS		0x0FFFFFFF


/* set bits - write-only */
#define INT_SET_BASE			0x40000080
/* clear bits - read/write */
#define INT_CLR_BASE			0x400000C0

void
interrupt_core( unsigned int core )
{
	PUT32(INT_SET_BASE + ((core & 0xf) << 4), 0x1);
}

void
clear_interrupt( unsigned int core )
{
	PUT32(INT_CLR_BASE + ((core & 0xf) << 4), 0xFFFFFFFF);
}

//
// sets the top bit (bit 31) of the outgoing message 					(VALIDBIT)
// sets the sender ID, determined by calling cpu_id(), in bits 28-29	(IDMASK)
// puts the user's message into bits 0-27 								(MSGBITS)
// returns a Boolean 
// 0 - msg not delivered (if dest MBOX is full)		[kernel ignores this]
// 1 - otherwise
//
unsigned int
send( unsigned int dest, unsigned int msg )
{
	unsigned int id = cpu_id();
	msg |= VALIDBIT;
	msg |= ( id << 28 );

	//write to corresponding mailbox if non-empty
	switch ( dest ){
		case 0 :
			if( GET32( 0x400000C4 ) == 0x00000000 ){
				PUT32( 0x40000080, msg );           //interrupt on MBox0
				PUT32( 0x40000084, msg ); 			//keep track of msg in MBox1
				return 1;
			}else{
				return 0;
			}	

		case 1 :
			if( GET32( 0x400000D0 ) == 0x00000000 ){
				PUT32( 0x40000090, msg );
				return 1;
			}else{
				return 0;
			}	

		case 2 :
			if( GET32( 0x400000E0 ) == 0x00000000 ){
				PUT32( 0x400000A0, msg );
				return 1;
			}else{
				return 0;
			}

		default :
			/*flash_lonum( 1 );*/
			return 0;
	}
}

//
// returns the message received in the corresponding MBOX
// returns NACK (zero) if a timeout occurs - i.e., if
// time expires and there is still no valid message to read
//
unsigned int
recv( unsigned int timeout )
{
	unsigned int message;
	unsigned int current, then;
	current = cpu_id();
	
	then = now_usec();
	do{
		switch ( current ){
			case 1 :
				message = GET32( 0x400000D0 );
				break;
			case 2 :
				message = GET32( 0x400000E0 );
			    break;
			default :
				message = ( SET_REGMSG(CORE_RUN, current, 0xcafe) | VALIDBIT );
				break;
		}
			
		if( message ){
			clear_interrupt(current);
			return message;
		}	
	}while ( usec_diff( now_usec(), then ) < timeout );

	

	return NACK;
}

//
// kernel code can call this instead of recv since it doesn't care about validity of the message
//
unsigned int
krecv( )
{
	unsigned int message = GET32( 0x400000C4 );
	PUT32( 0x400000C4, 0xFFFFFFFF );
	clear_interrupt(0);
	return message;
}

void _init_ipc()
{
	unsigned int i;

	for (i=0; i<NUM_CORES; i++) {
		// clear the mailbox
		if( i == 0 ){
			//clear core 0 mailboxes
			PUT32( 0x400000C0, 0xFFFFFFFF );
			PUT32( 0x400000C4, 0xFFFFFFFF );
		}else if( i == 1 ){
			//clear core 1 mailboxes
			PUT32( 0x400000D0, 0xFFFFFFFF );

		}else if( i == 2 ){
			//clear core 2 mailboxes
			PUT32( 0x400000E0, 0xFFFFFFFF );
		}else{
			//clear core 3 mailboxes
			PUT32( 0x400000F0, 0xFFFFFFFF );
		}
	}

	#define INT_IRQ	0x0F
	#define INT_FIQ	0xF0
	#define INT_NONE 0

	// mailboxes & interrupts
	PUT32(0x40000050, INT_FIQ);		// mbox 0 interrupts by FIQ; note: IRQ used by timer
	PUT32(0x40000054, INT_IRQ);	// mboxes 3 *does not* interrupt, for now
	PUT32(0x40000058, INT_IRQ);
	PUT32(0x4000005C, INT_NONE);

	return;
}

