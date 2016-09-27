#include "hype.h"

unsigned int fbInfoAddr;
unsigned int linenum;

extern void print_c (unsigned int, unsigned char*, unsigned int, unsigned int);

void add_new_line() {
  linenum++;
}

void print_to_asm(unsigned char *addr, unsigned int max, int l_i ) {
  unsigned int linenum_screen;
  if(l_i == 0) linenum_screen = linenum;
  else linenum_screen = l_i;
  print_c(fbInfoAddr, addr, linenum_screen, max);
  add_new_line();
}

void initiate_print(unsigned int x) {
  fbInfoAddr = x;
  linenum = 1;
}

void shift_up_by_line() {
}

//Print the value of some variable in hex format 
void printhex (unsigned int num) {
  unsigned int  i, max;
  int q,r;
  unsigned char n[15], m[15];
  unsigned char * addr;
  max = 0;
  for (i=0; i<11; i++) {
    q = num/16;
    r = num - 16*q;
    if(r<10)
      n[i] = 48+r;
    else  
      n[i] = 65+r-10;
    num = q;
    if (num == 0) {
      max = i+1;
      break;
    }
   }
  m[0] = '0'; 
  m[1] = 'x'; 
  for (i=0; i<max; i++) {
    m[i+2] = n[max-1-i];
  }
  addr = m;
  print_to_asm(addr,max+2,0);
}

//Print the value of some variable in dec format 
void printdec (unsigned int num) {
  unsigned int  i, max;
  int q,r;
  unsigned char n[11], m[11];
  unsigned char * addr;
  max = 0;
  for (i=0; i<11; i++) {
    q = num/10;
    r = num - 10*q;
    n[i] = 48+r;
    num = q;
    if (num == 0) {
      max = i+1;
      break;
    }
  }
  for (i=0; i<max; i++) {
    m[i] = n[max-1-i];
  }
  addr = m;
  print_to_asm(addr,max,0);
}

//Print array of chars
void print_text(unsigned char text[]) {
  unsigned int max;
  max = 0;
  while (text[max] != '\0') max++;
  print_to_asm(text,max,0);
  text[max] = '\0';
}

//Print debug message
void print_debug(unsigned char text[], unsigned int num) {
  print_text(text);
  printdec(num);
}

void print_debug_hex(unsigned char text[], unsigned int num) {
  print_text(text);
  printhex(num);
}

unsigned char ad[50] = "Address-";
unsigned char va[50] = "Value-";

void print_addr_val(unsigned int addr, unsigned int val) {
  print_debug_hex(ad,addr);
  print_debug_hex(va,val);
  add_new_line();
}

void _init_video() {
  init_video_code();
}

