/**
 * (C) 2007-18 - ntop.org and contributors
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not see see <http://www.gnu.org/licenses/>
 *
 */

#ifndef _N2N_EVENT_H_
#define _N2N_EVENT_H_

#include <stdio.h>

typedef enum {
    N2N_EVENT_TIMEOUT,    //event of timeout(10s)
    N2N_EVENT_TUN,      //data from tun
    N2N_EVENT_UDP,      //data from udp
    N2N_EVENT_QUIT,     //event of quit
    N2N_EVENT_MAX
} n2n_event_type;

typedef struct {
    n2n_event_type type;
    void *data;
    int len;
} n2n_event;

void *n2n_create_event_queue(void);
void n2n_event_send(void *queue, n2n_event_type type, void *data, int len);
n2n_event *n2n_event_wait(void *queue);
void n2n_event_release(void *queue, n2n_event *event);
void n2n_destroy_event_queue(void *queue);

#endif /* _N2N_EVENT_H_ */
