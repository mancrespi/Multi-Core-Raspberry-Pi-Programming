#include "syscall.h"

/***************************
 Emanuelle Crespi
 ENEE447 - Operating Systems
 Spring 2016
 ***************************/

/*********************************************************************************************************
  The following touches on some basic concepts when implementing a basic syscall facility
  for a general purpose OS on the Raspberry Pi 2B.  The syscall wrapper initializes
  global defined variables, dev_type, func_type, and deviceID (assuming there is more 
  than one device to facilitate) with arguments passed through user code on 4 possible 
  user available system calls...

    1. read ( unsigned int device_type, unsigned int func, unsigned int id, char *buf, unsigned int len )
    2. write ( unsigned int device_type, unsigned int func, unsigned int id, char *buf, unsigned int len )
    3. newproc ( char *executable )
    4. newthread ( pfv_t entrypoint )

  Each of these functions invokes a call to syscall, where an interrupt on swi is initiated
  to enter SVC mode and handle the request in the sys_handler. The system level calls...

  	sysread ( char *buf, unsigned int len )
  	syswrite ( char *buf, unsigned int len )
  	syscall_newproc ( char *executable )
  	syscall_newthread ( int entrypoint )

  will only print to HDMI, indicating we have arrived to the appropriate handler.

  It is also important to note that the device id is not actually indexed anywhere in the
  code below, since it is unknown how many devices are to be considered in the design. 
  It should be simple enough to index the device along a global array to be sure that the 
  system call is performed on the appropriate device.  Also function pointers are still not 
  compiling correctly [-_-] so dummy functions are used to indicate the desired functionality.

  The user is expected to invoke system calls 1-4 by indicating the "device_type" and "func" 
  with enumeration types defined in syscall.h, and passing whatever other arguments are 
  necessary for the particaulr system call. The null function is available at the user/system
  level to indicate a non-existant device and/or function and only prints to the screen.

  [user code runs on core 1 which branches to z_applications in USER mode]
 ********************************************************************************************************/

unsigned char sr_msg[20] = "Read\n";
unsigned char swr_msg[20] = "Write\n";
unsigned char sp_msg[50] = "New Proc Initiated\n";
unsigned char st_msg[50] = "New Thread Initiated\n";
unsigned char d[20] = "ID:\n";
unsigned char entry[20] = "Entry:\n";

unsigned char syshello[20] = "Sys Handler!!!\n";
unsigned char Null[20] = "Null!\n";

//Global device and function type for syscall handler to access
unsigned int dev_type;
unsigned int func_type;
unsigned int deviceID;

/***************************SYS CALLS*******************************************************/
static void sysread ( char *buf, unsigned int len ){
	print_text( sr_msg );
}

static void syswrite ( char *buf, unsigned int len ){
	print_text( swr_msg );
}

static void syscall_newproc ( char *executable ){
	print_text( sp_msg );
}

static void syscall_newthread ( int entrypoint ){
	print_text(entry);
	printhex( entrypoint );
	print_text( st_msg );
}

/***************************USER/SYS CALLS**************************************************/
void null ( void ){
	print_text( Null );
}

/***************************USER CALLS******************************************************/
void read ( unsigned int device_type, unsigned int func, unsigned int id, 
													char *buf, unsigned int len ){
	syscall ( func, device_type, id, buf, len );
}

void write ( unsigned int device_type, unsigned int func, unsigned int id, 
													char *buf, unsigned int len ){
	syscall ( func, device_type, id, buf, len );
}

void newproc ( char *executable ){
	syscall ( SYSCALL_NEWPROC, DEVICE_NULL, -1, executable, 0 );
}

void newthread ( pfv_t entrypoint ){
	syscall ( SYSCALL_NEWTHREAD, DEVICE_NULL, -1, "", 0 );
}


/**************************REMOVED*******************REMOVED********************/
//5 device/nondev functions with READ/WRITE/NULL interface
	/*pfv_t nondev_funcs[SYSCALL_MAX] = {Null, syscall_newproc, syscall_newthread};
	pfv_t led_funcs[DEVCALL_MAX] = {Null, sysread, syswrite};
	pfv_t monitor_funcs[DEVCALL_MAX] = {Null, sysread, syswrite};
	pfv_t sdcard_funcs[DEVCALL_MAX] = {Null, sysread, syswrite};
	pfv_t clocks_funcs[DEVCALL_MAX] = {Null, sysread, syswrite};

	static Interface devices[DEVICE_MAX] = {
		nondev_funcs,
		led_funcs,
		monitor_funcs,
		sdcard_funcs,
		clocks_funcs
	};*/
/**************************REMOVED*******************REMOVED********************/


//Wrapper for sys call
void syscall( unsigned int function, unsigned int type, unsigned int device_id, 
									char *args, unsigned int arg_size ){
	
	dev_type = type;
	func_type = function;
	deviceID = device_id;

	////////DEBUG/////////
	//printdec(dev_type);
	//printdec(func_type);
 	//////////////////////

	asm( "svc #0" );
}

void sys_handler( char *args, unsigned int arg_size ){

	//pfv_t perform_task;
	unsigned int device = dev_type;
	unsigned int function = func_type;
	unsigned int deviceid = deviceID;

	
	////////DEBUG/////////
	//printdec(dev_type);
	//printdec(func_type);
 	//////////////////////


 	//Device type: Null/Default
 	if ( device == DEVICE_NULL ){
 		
 		/*****************REMOVED*******************/
 		//Index through array of functions
 			//perform_task = devices[device][function];
 		/*****************REMOVED*******************/

 		switch ( function ){
 			case SYSCALL_NULL:
 				/*********REMOVED********/
 					//perform_task();
 				/*********REMOVED********/
 				
 				null();
 				blink_led(GRN);
 				break;
 			case SYSCALL_NEWPROC:
 				/*********REMOVED********/
 					//perform_task(args);
 				/*********REMOVED********/

 				syscall_newproc( args );
 				blink_led(GRN);
 				break;
 			case SYSCALL_NEWTHREAD:
 				/*********REMOVED*****************/
 				//uses an arbitrary funtion (null)
 					//perform_task( &null );
 			 	/*********REMOVED******************/

 				syscall_newthread( 0x1234 ); //passing a dummy value
 				blink_led(GRN);
 				break;
 			default:
 				blink_led(RED);				//DEBUG
 		}

 	}else if ( ( device == DEVICE_LED ) | ( device == DEVICE_MONITOR )
 				| ( device == DEVICE_SDCARD ) | ( device == DEVICE_CLOCKS ) ){
 		print_text( d );
		printhex( deviceid );

 		/*****************REMOVED*******************/
 		//Index through array of functions
 			//perform_task = devices[device][function];
 		/*****************REMOVED*******************/

 		switch ( function ){
 			case DEVCALL_NULL:
 				/*********REMOVED********/
 				//perform_task();
 				/*********REMOVED********/

 				null();
 				blink_led(GRN);
 				break;
 			case DEVCALL_READ:
 				/****************REMOVED***********/
 				//perform_task(args, arg_size);
 				/****************REMOVED***********/

 				sysread(args, arg_size);
 				blink_led(GRN);
 				break;
 			case DEVCALL_WRITE:
 				/**************REMOVED*************/
 				//perform_task(args, arg_size);
 				/**************REMOVED*************/

 				syswrite(args, arg_size);
 				blink_led(GRN);
 				break;
 			default:
 				blink_led(RED);				//DEBUG
 		}

 	}else{
 		blink_led(RED);				//DEBUG
 	}
 	
}