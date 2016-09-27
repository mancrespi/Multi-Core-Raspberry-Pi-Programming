
/*
 * llist.c
 *
 * routines for a doubly linked list package
 */

#include "llist.h"


/*
 * lp is list pointer
 */
llobject_t *
ll_pop(lp)
llobject_t *lp;
{
    if (LL_IS_EMPTY(lp)) {
		return LL_NULL;
    }
    return LL_DETACH(lp, lp->next);
}


/*
 * lp is list pointer
 */
llobject_t *
ll_last(lp)
llobject_t *lp;
{
    if (LL_IS_EMPTY(lp)) {
		return LL_NULL;
    }
    return lp->prev;
}

/*
 * lp is list pointer
 */
llobject_t *
ll_first(lp)
llobject_t *lp;
{
    if (LL_IS_EMPTY(lp)) {
		return LL_NULL;
    }
    return lp->next;
}



/*
 * ip is the insertion point (insert after this node)
 * ep is the element pointer (node to insert)
 */
llobject_t *
ll_r_insert(ip, ep)
llobject_t *ip;
llobject_t *ep;
{
    llobject_t *tp = ip->next;

    tp->prev = ep;
    ep->next = tp;
    ip->next = ep;
    ep->prev = ip;

    return ep;
}


/*
 * ep is the element pointer (element to remove from list)
 */
llobject_t *
ll_detach(lp, ep)
llobject_t *lp;
llobject_t *ep;
{
    if (LL_IS_EMPTY(lp) || lp == ep) {
		return LL_NULL;
    }

    (ep->prev)->next = ep->next;
    (ep->next)->prev = ep->prev;

    return ep;
}



llobject_t *
ll_assert(ep, msg, file, line)
llobject_t *ep;
char *msg;
char *file;
int line;
{
    if (!ep) {
		// die(ERRNO_ASSERT); - need to do some sort of logging
		return LL_NULL;
    }
    return ep;
}


/*
 * frees the list
llobject_t *
ll_destroy(lp)
llobject_t *lp;
{
    llobject_t *tp;

    LL_EACH(lp, tp, llobject_t) {
		free(tp);
    }
    LL_INIT(lp);
    return lp;
}

 */


llobject_t *
ll_insert(lp, ep, cmp)
llobject_t *lp;
llobject_t *ep;
int (*cmp)();
{
    llobject_t *tp;

    if (LL_IS_EMPTY(lp)) {
		return LL_PUSH(lp, ep);
    }

    LL_EACH(lp, tp, llobject_t) {
		if (lp == tp->next) {
			return LL_APPEND(lp, ep);
		} else if ((*cmp)(ep, tp->next) < 0) {
			return LL_R_INSERT(tp, ep);
		}
    }
	// die(ERRNO_ASSERT); -- need to do some form of logging
    return LL_NULL;
}





