/*
 * Copyright © 2010 Intel Corporation
 * Copyright © 2010 Francisco Jerez <currojerez@riseup.net>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 */

#ifndef _IMG_LIST_H_
#define _IMG_LIST_H_

#include "img_defs.h"

/* classic doubly-link circular list */
typedef struct PVRSRV_LIST_HEAD {
    struct PVRSRV_LIST_HEAD *next;
    struct PVRSRV_LIST_HEAD *prev;
}PVRSRV_LIST;

#define LIST_HEAD_INIT(name) { &(name), &(name) }

#define LIST_HEAD(name) \
		PVRSRV_LIST name = LIST_HEAD_INIT(name)

static INLINE void
list_init(PVRSRV_LIST *list)
{
    list->next = list->prev = list;
}

static INLINE void
__list_add(PVRSRV_LIST *entry,
	    PVRSRV_LIST *prev,
	    PVRSRV_LIST *next)
{
    next->prev = entry;
    entry->next = next;
    entry->prev = prev;
    prev->next = entry;
}

static INLINE void
list_add(PVRSRV_LIST *entry, PVRSRV_LIST *head)
{
    __list_add(entry, head, head->next);
}

static INLINE void list_add_tail(PVRSRV_LIST *new_entry, PVRSRV_LIST *head)
{
	__list_add(new_entry, head->prev, head);
}

static INLINE void
__list_del(PVRSRV_LIST *prev, PVRSRV_LIST *next)
{
    next->prev = prev;
    prev->next = next;
}

static INLINE void
list_del(PVRSRV_LIST *entry)
{
    __list_del(entry->prev, entry->next);
    list_init(entry);
}

static INLINE void list_del_init(PVRSRV_LIST *entry)
{
	__list_del(entry->prev, entry->next);
	list_init(entry);
}

/**
 * list_move - delete from one list and add as another's head
 * @list: the entry to move
 * @head: the head that will precede our entry
 */
static INLINE void list_move(PVRSRV_LIST *list, PVRSRV_LIST *head)
{
	__list_del(list->prev, list->next);
	list_add(list, head);
}

/**
 * list_move_tail - delete from one list and add as another's tail
 * @list: the entry to move
 * @head: the head that will follow our entry
 */
static INLINE void list_move_tail(PVRSRV_LIST *list,
				  PVRSRV_LIST *head)
{
	__list_del(list->prev, list->next);
	list_add_tail(list, head);
}

static INLINE IMG_BOOL
list_is_empty(PVRSRV_LIST *head)
{
    return (head->next == head) ? IMG_TRUE : IMG_FALSE;
}

#ifndef container_of
#define container_of(ptr, type, member) \
    (type *)((char *)(ptr) - (char *) &((type *)0)->member)
#endif

#define list_entry(ptr, type, member) \
    container_of(ptr, type, member)

#define list_first_entry(ptr, type, member) \
    list_entry((ptr)->next, type, member)

#define __container_of(ptr, sample, member)				\
    (void *)((char *)(ptr)						\
	     - ((char *)&(sample)->member - (char *)(sample)))

#define list_for_each_entry(pos, head, member)				\
    for (pos = __container_of((head)->next, pos, member);		\
	 &pos->member != (head);					\
	 pos = __container_of(pos->member.next, pos, member))

#define list_for_each_entry_safe(pos, tmp, head, member)		\
    for (pos = __container_of((head)->next, pos, member),		\
	 tmp = __container_of(pos->member.next, pos, member);		\
	 &pos->member != (head);					\
	 pos = tmp, tmp = __container_of(pos->member.next, tmp, member))

#endif //_IMG_LIST_H_
