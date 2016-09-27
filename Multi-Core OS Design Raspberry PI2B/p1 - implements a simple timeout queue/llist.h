/*
 * llist.h
 *
 * its about time i had access to a decent llist package
 */

/*
 * instructions for use:
 *
 * for example, you have a structure such as
 *
 *     struct foo {
 *         int i1;
 *         int i2;
 *     }
 *
 * that you want to use in a linked list format.
 *
 * FIRST, redefine it as
 *
 *     struct foo {
 *         LL_PTRS;
 *         int i1;
 *         int i2;
 *     }
 *
 * this puts the pointer declarations into the struct
 * in the correct order & with the correct name, etc.
 *
 * SECOND, declare the following items:
 *
 *     llobject_t ANCHOR;
 *     struct foo *listptr = (struct foo *)&ANCHOR;
 *
 * this gives you the head of the list; the way the package
 * works is you waste a linked list object as the head, but
 * it's the only way to know you've hit the end (or beginning)
 * of the list.  it's obviously a better use of space to have
 * ANCHOR be a llobject_t than a struct foo, also.
 *
 * THIRD, you need to LL_INIT the list before you use it,
 * otherwise your program will core dump.  note that
 * whenever you do operations on the list, you should
 * refer to it as listptr, not ANCHOR or &ANCHOR.
 *
 *     LL_INIT(listptr);
 *
 * this is the right format.
 *
 * FOURTH, use the macros and not the pointers or functions
 * directly - there is a bit of null pointer checking that
 * goes on when you use the macros, and they are designed to
 * hide the ANCHOR from you ... you shouldn't have much of
 * a reason to need to see the ANCHOR, and if you want to
 * turn off the pointer checking, just set LL_DEBUG to 0.
 *
 * function descriptions:
 *
 *  llobject_t *
 *  LL_NEXT(listptr, elementp)
 *    returns the following item in the list; if the item in
 *    question is the last in list, returns the first item in list
 *
 *  llobject_t *
 *  LL_PREV(listptr, elementp)
 *    returns the previous item in the list; if the item in
 *    question is the first in list, returns the last item in list
 *
 *  LL_EACH(listptr, elementp, pointer-type)
 *    iterates through the list, starting with the first & ending
 *    with the last item.  to be used like this:
 *        struct foo *tmp;
 *        LL_EACH (listptr, tmp, pointer-type) {
 *            do something with tmp
 *        }
 *
 *  LL_INIT(listptr)
 *    to be called before ANYTHING is done with a given list structure
 *
 *  int
 *  LL_IS_EMPTY(listptr)
 *    boolean: returns whether or not the list has 0 items in it
 *
 *  llobject_t *
 *  LL_R_INSERT(insertpoint, elementp)
 *    inserts the element AFTER the insert point element, returns element
 *
 *  llobject_t *
 *  LL_L_INSERT(insertpoint, elementp)
 *    inserts the element BEFORE the insert point element, returns element
 *
 *  llobject_t *
 *  LL_PUSH(listptr, elementp)
 *    inserts the element at the HEAD of the list, returns element
 *
 *  llobject_t *
 *  LL_APPEND(listptr, elementp)
 *    inserts the element at the END of the list, returns element
 *
 *  llobject_t *
 *  LL_DETACH(listptr, elementp)
 *    removes the element from the list, returns element
 *
 *  llobject_t *
 *  LL_POP(listptr)
 *    removes the TOP element from the list,
 *    returns element or NULL if list empty
 *
 *  llobject_t *
 *  LL_ASSERT(elementp)
 *    prints out an informative message if elementp is not null.
 *    returns element.
 *
 *  llobject_t *
 *  LL_FIRST(listptr)
 *  LL_HEAD(listptr)
 *  LL_TOP(listptr)
 *    returns first element in list if nonempty. otherwise returns NULL
 *
 *  llobject_t *
 *  LL_LAST(listptr)
 *  LL_BOTTOM(listptr)
 *  LL_TAIL(listptr)
 *    returns last element in list if nonempty. otherwise returns NULL
 */



/*
 * this macro should appear at the top of any struct
 * to be used as a linked list
 */
#define LL_PTRS \
    struct _llp *prev; \
    struct _llp *next

typedef struct _llp {
    LL_PTRS;
} llobject_t;


/*
 * for debugging, leave set to 1 ...
 * once we want it to run fast & we're
 * relatively sure stupid errors are
 * gone, feel free to turn off - it does
 * add about 20-30% overhead
 */
#define LL_DEBUG 0
#if LL_DEBUG
#define LLP		LL_ASSERT
#else
#define LLP(ptr)	((llobject_t *)ptr)
#endif


#define LL_NULL		((llobject_t *)0)



/*
 * function declarations
 */

extern llobject_t *ll_r_insert(llobject_t *lp, llobject_t *ep);
extern llobject_t *ll_detach(llobject_t *lp, llobject_t *ep);
extern llobject_t *ll_insert(llobject_t *lp, llobject_t *ep, int (*cmp)());
extern llobject_t *ll_first(llobject_t *ep);
extern llobject_t *ll_pop(llobject_t *ep);
extern llobject_t *ll_assert(llobject_t *ep, char *msg, char *file, int line);
extern llobject_t *ll_destroy(llobject_t *lp);


/*
 * macro functions
 */

/* NEXT and PREV should not be used in llist.h or llist.c as they skip the ANCHOR */
#define LL_NEXT(lp, ep)	(LLP(ep)->next == LLP(lp) ? LLP(lp)->next : LLP(ep)->next)
#define LL_PREV(lp, ep)	(LLP(ep)->prev == LLP(lp) ? LLP(lp)->prev : LLP(ep)->prev)

#define LL_EACH(lp, ep, t) \
	for (ep = (t *)(LLP(lp)->next); LLP(ep) != LLP(lp); ep = (t *)(LLP(ep)->next))

#define LL_INIT(lp) \
	(LLP(lp)->prev = LLP(lp)->next = LLP(lp))

#define LL_IS_EMPTY(ep) \
	(LLP(ep)->next == LLP(ep))

#define LL_R_INSERT(ip, ep)	ll_r_insert(LLP(ip), LLP(ep))
#define LL_L_INSERT(ip, ep)	LL_R_INSERT(LLP(ip)->prev, ep)
#define LL_PUSH(lp, ep)		LL_R_INSERT(lp, ep)
#define LL_APPEND(lp, ep)	LL_L_INSERT(lp, ep)

#define LL_DETACH(lp, ep)	ll_detach(LLP(lp), LLP(ep))
#define LL_POP(lp)		ll_pop(LLP(lp))

#define LL_ASSERT(ep)		ll_assert((llobject_t *)(ep), #ep, __FILE__, __LINE__)
#define LL_DESTROY(lp)		ll_destroy(LLP(lp))

#define LL_FIRST(lp)		ll_first(LLP(lp))
#define LL_LAST(lp)		ll_last(LLP(lp))
#define LL_TOP			LL_FIRST
#define LL_HEAD			LL_FIRST
#define LL_BOTTOM		LL_LAST
#define LL_TAIL			LL_LAST


