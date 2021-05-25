//
//  n2n_event.c
//  Tunnel
//
//  Created by samuelsong on 2021/5/25.
//

#include "n2n_event.h"
#include <stdlib.h>
#import <Foundation/Foundation.h>

#define N2N_MAX_SLOT (2)
#define N2N_MAX_BUFF (2048)

#define N2N_LOCK(lock) dispatch_semaphore_wait((lock), DISPATCH_TIME_FOREVER)
#define N2N_UN_LOCK(lock) dispatch_semaphore_signal((lock))

typedef struct n2n_event_node {
    n2n_event event;
    uint8_t buffer[N2N_MAX_BUFF];
    struct n2n_event_node *next;
} n2n_event_node;

typedef struct {
    //cause Apple deprecate sem_init, so use gcd semaphore below
    dispatch_semaphore_t free_sem, event_sem, lock;
    n2n_event timeout_event;
    n2n_event_node data_event[N2N_MAX_SLOT];
    n2n_event_node *free_list;
    n2n_event_node *event_list;
} n2n_event_queue;

// Priate
static void queue_init(n2n_event_queue *queue) {
    if (queue) {
        memset((void *)queue, 0, sizeof(*queue));
        queue->free_sem = dispatch_semaphore_create(3); //3 free slot
        queue->event_sem = dispatch_semaphore_create(0); //no event at first
        queue->lock = dispatch_semaphore_create(1); //work as a lock
        queue->data_event[0].next = queue->data_event + 1;
        queue->free_list = queue->data_event;
        queue->timeout_event.type = N2N_EVENT_TIMEOUT; //timeout event init
    }
}

// Public
void *n2n_create_event_queue(void) {
    printf("Omniedge n2n n2n_create_event_queue\n");
    n2n_event_queue *queue = malloc(sizeof(n2n_event_queue));
    if (queue) {
        queue_init(queue);
    }
    return queue;
}

void n2n_event_send(void *queue, n2n_event_type type, void *data, int len) {
    printf("Omniedge n2n n2n_event_send: %d\n", len);
    
}

n2n_event *n2n_event_wait(void *handle) {
    printf("Omniedge n2n n2n_event_wait\n");
    if (handle == NULL) {
        return NULL;
    }
    n2n_event_queue *queue = (n2n_event_queue *)handle;
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_semaphore_wait(queue->event_sem, timeout); //wait for 10s for event
    n2n_event *event = NULL;
    N2N_LOCK(queue->lock);
    event = &(queue->timeout_event);
    N2N_UN_LOCK(queue->lock);
    return event;
}

void n2n_event_release(void *queue, n2n_event *event) {
    if (event == NULL) {
        return;
    }
    if (event->type == N2N_EVENT_TIMEOUT) {
        return;
    }
}
void n2n_destroy_event_queue(void *queue) {
    if (queue) {
        free(queue);
    }
}
