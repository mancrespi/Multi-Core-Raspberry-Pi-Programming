//
// timeout queue
//

#include "os.h"
#include "llist.h"	
#include "time.h"

//structure for an event
//PROBLEMS: OS crashes when trying to make a call through some
//pfv_t type.  For now the blink function is used to indicate a function call
struct event {
	LL_PTRS;
	int timeout;
	int repeat_interval;
	pfv_t go;
	unsigned int data;
};

#define MAX_EVENTS	8
struct event queue[ MAX_EVENTS ];

// list anchors for now (never used directly)
llobject_t TQ;
llobject_t FL;

struct event *timeoutq;
struct event *freelist;

unsigned int then_usec;

//
// sets up concept of local time
// initializes the timeoutq and freelist
// fills the freelist with entries
// timeoutq is empty
//
void
init_timeoutq()
{
	int i;

	then_usec = gettime();

	timeoutq = (struct event *)&TQ;
	LL_INIT(timeoutq);
	freelist = (struct event *)&FL;
	LL_INIT(freelist);

	for (i=0; i<MAX_EVENTS; i++) {
		struct event *ep = &queue[i];
		LL_PUSH(freelist, ep);
	}

	return;
}


//
// account for however much time has elapsed since last update
// return timeout or MAX
//
int
bring_timeoutq_current()
{
	unsigned int now = gettime();
	unsigned int diff = now - then_usec;
	int wait = diff;

	if(!(LL_IS_EMPTY(timeoutq))){
		struct event *current = LL_HEAD(timeoutq);
		current->timeout -= diff;
		//flash_led(5,RED,5);
	}

	//UPDATE relative time
	then_usec = now;

	// your code goes here
	return wait;
}


//
// get a new event structure from the freelist,
// initialize it, and insert it into the timeoutq
// 
void
create_timeoutq_event(int timeout, int repeat, pfv_t function, unsigned int data)
{
	struct event *new = LL_POP(freelist);
	struct event *temp = LL_HEAD(timeoutq);
	new->timeout = timeout;
	new->repeat_interval = repeat;
	new->go = function;
	new->data = data;

	//Empty list
	if(!temp){
		//insert to empty list
		LL_PUSH(timeoutq,new);
		return;
	}

    //iterates through list to insert event
    LL_EACH(timeoutq, temp, struct event){
        if(new->timeout < temp->timeout){//new time < temp time
            //insert to left of temp
            LL_L_INSERT(temp,new);
            
            //decrement time of next event
            temp->timeout -= new->timeout;
            return;
        }else{
            //decrement relative time of event (continue to next iteration)
            new->timeout -= temp->timeout;
        }
    }
    
    //only hit this case after walking the list (append to the end)
    LL_APPEND(timeoutq,new);
    return;

}

/* 
    Checks the head of the timeout queue to see whether the event should be executed.
    this is determined by observing the timeout has reached ONE_MSEC or less
 
    Events that are re-inserted must have a rep argument of 1 otherwise they are added
    to the free_list
    
    returns 1 when an event has been succesfully handled
    returns 0 otherwise
*/
int
handle_timeoutq_event( )
{
	
	if( !LL_IS_EMPTY( timeoutq ) ){
		//check if timeout has expired
		struct event *current = LL_HEAD(timeoutq);

		if( current->timeout <= ONE_MSEC){
			int rep = current->repeat_interval;

			//execute function
			blink_led(current->data);		//blinks led to simulate execution...
            
			//re-insert if there is a repeat interval
			if(rep != 0){
                LL_POP(timeoutq);
				create_timeoutq_event(rep,rep,current->go,current->data);
			}else{
				//otherwise, insert into the freelist
				LL_PUSH(freelist,LL_POP(timeoutq));
			}

			return 1; //event handled
		}else{

			return 0;	//event not handled (wait time)
		}	
	}else{	
		return 0; //event not handled (empty list)
	}
}
