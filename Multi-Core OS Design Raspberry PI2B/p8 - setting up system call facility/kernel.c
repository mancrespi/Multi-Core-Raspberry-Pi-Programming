#include "hype.h"

extern unsigned int interrupt_core( unsigned int );
unsigned char kmessage[50] = "C0 - Kernel....";
unsigned char one[20] = "1...";
unsigned char two[20] = "2...";
unsigned char three[20] = "3...";
unsigned char four[20] = "4...";
unsigned char five[20] = "5...!!!";
unsigned char *cnt[5] = {one, two, three, four, five};

void
kernel()
{
	unsigned int then, now, delta;
	init_video_code();
	
	#include "initf.auto"
	print_text(kmessage);
	
	then = now_usec();
	unsigned int i = 0;
	while (1) {
		now = now_usec();
		delta = usec_diff( now, then );
		if (delta > 5 * ONE_SEC) {
			then = now;
			interrupt_core(1);
			while (1) continue;
		}else{
			print_text(cnt[i++]);
		}
	}
}

