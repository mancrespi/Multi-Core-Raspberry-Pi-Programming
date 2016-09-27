#include "hype.h"

//
// Your task: map it so that led.c works ... 
// it is currently using these two sets of addresses:
//
// #define GPFSEL3 0x3F20000C
// #define GPFSEL4 0x3F200010
// #define GPSET1  0x3F200020
// #define GPCLR1  0x3F20002C
//
// #define V_GPFSEL3 0x0020000C
// #define V_GPFSEL4 0x00200010
// #define V_GPSET1  0x00200020
// #define V_GPCLR1  0x0020002C
//
// ... and only the ones that go to 0x3F2xxxxx work. The "V_" addresses
// do not currently work ... they are going to "virtual" locations that
// end up having nothing to do with the GPIOs.
//
// You are to use virtual memory to map the following:
//
//	0x002xxxxx -> 0x3F2xxxxx	(so the GPIOs work)
//	0x3F2xxxxx -> 0x3F2xxxxx	(so the GPIOs work)
//	0x400xxxxx -> 0x400xxxxx	(so the clock & timer accesses work)
//
// and you'll also want to map this, so that your code & data still work:
//
//	0x000xxxxx -> 0x000xxxxx
//

#define	PT_START	0x00100000
#define PT_END		0x00101000

unsigned int *pagetable;


//
// sets up a mapping in the page table between the VPN and PFN, which are
// represented by the vaddr and paddr values
// note that io addresses need to have different information in the PTE
//
void	map( unsigned int vaddr, unsigned int paddr, int io_addr )
{
	unsigned int vpn = vaddr, pfn = paddr, entry = 0;
	//section based format for mapping 1MB region
	entry |= ( pfn << 20 );
	entry |= 2;										//indicate this entry is for 1MB section
	entry |= ( ( 1<<10 ) | ( 1<<11 ) ); 			//read/write full access
	pagetable[vpn] = entry;
}


// turns on the system
void	enable_vm()
{
	unsigned int ttbcr_config = 0, ttbr0_config = PT_START;
	unsigned int sctlr_config;
	
	map( 0x002, 0x3F2, 1 );
	map( 0x3F2, 0x3F2, 1 );
	map( 0x000, 0x000, 0 );
	map( 0x400, 0x400, 0 );
	
	writeDACR(1);								//client priveledges
	writeTTBCR( ttbcr_config );				
	writeTTBR0( ttbr0_config );
	sctlr_config = readSCTLR();
	writeSCTLR( sctlr_config | 1 );				//enables VM
}

// first set everything to zeroes
void	initialize_table()
{
	unsigned int i;

	for(i = 0; i <= 4096; i++){
		pagetable[i] = 0;
	}
}


// this is actually run by core0 at startup
void	_init_vm()
{
	pagetable = (unsigned int *)PT_START;
	initialize_table();
}
