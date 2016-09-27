#include "hype.h"

enum device_types {
	DEVICE_NULL,
	DEVICE_LED,
	DEVICE_MONITOR,
	DEVICE_SDCARD,
	DEVICE_CLOCKS,
	/* add new ones here */
	DEVICE_MAX
};

enum syscalls_dev {
	DEVCALL_NULL,
	DEVCALL_READ,
	DEVCALL_WRITE,
	/* add new ones here */
	DEVCALL_MAX
};

enum syscalls_nondev {
	SYSCALL_NULL,
	SYSCALL_NEWPROC,
	SYSCALL_NEWTHREAD,
	/* add new ones here */
	SYSCALL_MAX
};

//Sys Calls
extern int syscall_read (int device_type, int id, char *buf, int len);
extern int syscall_write (int device_type, int id, char *buf, int len);
extern int syscall_new_process (char *executable);
extern int syscall_new_thread (pfv_t entrypoint);
extern void yield(void);

//User calls
extern void null ( void );
extern int read ( char *args, unsigned int len );
extern int write ( char *args, unsigned int len );
extern int newproc ( char *args, unsigned int len );
extern int newthread ( char *args, unsigned int len );

//Wrapper
extern int syscall(int function, int device_id, char *args, int arg_size);

