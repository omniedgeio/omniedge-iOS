//
//  n2n_event.c
//  Tunnel
//
//  Created by samuelsong on 2021/5/25.
//

#include "n2n_event.h"

void *n2n_create_event_queue(void) {
    printf("Omniedge n2n n2n_create_event_queue\n");
    return NULL;
}

void n2n_event_send(void *queue, n2n_event_type type, void *data, int len) {
    printf("Omniedge n2n n2n_event_send: %d\n", len);
}

n2n_event *n2n_event_wait(void *queue) {
    return NULL;
}

void n2n_event_release(void *queue, n2n_event *event) {
    
}
void n2n_destroy_event_queue(void *queue) {
    
}
