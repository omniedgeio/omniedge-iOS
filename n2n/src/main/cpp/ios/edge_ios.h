//
//  edge_ios.h
//  n2n
//
//  Created by samuel.song.bc@gmail.com on 2021/5/31.
//

#ifndef edge_ios_h
#define edge_ios_h

#include <stdio.h>

typedef enum {
    IOS_FD_TUNNEL,  //tuntap
    IOS_FD_UDP,     //udp
    IOS_FD_MGR      //manage socket
} ios_fd_type;

void *ios_create_bridge(void);
int ios_get_fd(void *bridge, ios_fd_type type);
int ios_write_data(void *bridge, ios_fd_type type, const void *data, int len);
int ios_receive_tun_data(void *bridge, const void *data, int len);
int ios_receive_udp_data(void *bridge, const void *data, int len);
int ios_receive_mgr_data(void *bridge, const void *data, int len);
void ios_destroy_bridge(void *handle);

#endif /* edge_ios_h */
