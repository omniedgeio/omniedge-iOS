//
//  edge_ios.c
//  n2n
//
//  Created by samuel.song.bc@gmail.com on 2021/5/31.
//

#include "edge_ios.h"
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    int tun_read_fd;
    int tun_write_fd;
    int udp_read_fd;
    int udp_write_fd;
    int mgr_read_fd;
    int mgr_write_fd;
} ios_io_bridge;

#ifdef __IOS_TEST__
static void *listen_thread(void *param) {
    int fd[3] = {0};
    int *list = (int *)param;
    fd[0] = list[0];
    fd[1] = list[1];
    fd[2] = list[2];
    while (1) {
        int rc, max_sock = 0;
        fd_set socket_mask;
        struct timeval wait_time;
        FD_ZERO(&socket_mask);
        FD_SET(fd[0], &socket_mask);
        FD_SET(fd[1], &socket_mask);
        FD_SET(fd[2], &socket_mask);
        max_sock = max(max(fd[0], fd[1]), fd[2]);
        wait_time.tv_sec = 300;
        wait_time.tv_usec = 0;
        printf("start select...: %d\n", max_sock + 1);
        rc = select(max_sock + 1, &socket_mask, NULL, NULL, &wait_time);
        printf("wake from select: %d\n", rc);
        if (rc > 0) {
            if (FD_ISSET(fd[0], &socket_mask)) {
                char buffer[1024] = {0};
                ssize_t len = read(fd[0], buffer, 1024);
                printf("tun data: %zd, %s\n", len, buffer);
            }
            
            if (FD_ISSET(fd[1], &socket_mask)) {
                char buffer[1024] = {0};
                ssize_t len = read(fd[1], buffer, 1024);
                printf("udp data: %zd, %s\n", len, buffer);
            }
            
            if (FD_ISSET(fd[2], &socket_mask)) {
                char buffer[1024] = {0};
                ssize_t len = read(fd[2], buffer, 1024);
                printf("mgr data: %zd, %s\n", len, buffer);
                if (strcmp(buffer, "stop") == 0) {
                    break;
                }
            }
        } else if (rc == 0) {
            printf("select timeout\n");
        }
    }
    printf("game over\n");
    
    return NULL;
}

static int s_fd[3];
static void ios_start_test(int fd[3]) {
    s_fd[0] = fd[0];
    s_fd[1] = fd[1];
    s_fd[2] = fd[2];
    pthread_t listen_pid;
    pthread_create(&listen_pid, NULL, listen_thread, (void *)s_fd);
    pthread_detach(listen_pid);
}
#endif //__IOS_TEST__

static void init_fd(ios_io_bridge *bridge) {
    if (bridge->tun_read_fd == 0) {
        int fd[2] = {0};
        
        //tun
        int result = pipe(fd);
        //assert(result >= 0);
        if (result >= 0) {
            bridge->tun_read_fd = fd[0];
            bridge->tun_write_fd = fd[1];
        }
        
        //udp
        result = pipe(fd);
        //assert(result >= 0);
        if (result >= 0) {
            bridge->udp_read_fd = fd[0];
            bridge->udp_write_fd = fd[1];
        }

        //mgr
        result = pipe(fd);
        //assert(result >= 0);
        if (result >= 0) {
            bridge->mgr_read_fd = fd[0];
            bridge->mgr_write_fd = fd[1];
        }
    }
}

static void deinit_fd(ios_io_bridge *bridge) {
    if (bridge->tun_read_fd != 0) {
        close(bridge->tun_read_fd);
        close(bridge->tun_write_fd);
        close(bridge->udp_read_fd);
        close(bridge->udp_write_fd);
        close(bridge->mgr_read_fd);
        close(bridge->mgr_write_fd);
        memset(bridge, 0, sizeof(*bridge));
    }
}

void *ios_create_bridge(void) {
    static ios_io_bridge s_bridge;
    init_fd(&s_bridge);
    
#ifdef __IOS_TEST__
    int fd[3] = {0};
    fd[0] = ios_get_fd(&s_bridge, IOS_FD_TUNNEL);
    fd[1] = ios_get_fd(&s_bridge, IOS_FD_UDP);
    fd[2] = ios_get_fd(&s_bridge, IOS_FD_MGR);
    ios_start_test(fd);
#endif //__IOS_TEST__
    
    return &s_bridge;
}

int ios_get_fd(void *handle, ios_fd_type type) {
    if (handle == NULL) {
        return 0;
    }
    ios_io_bridge *bridge = (ios_io_bridge *)handle;
    switch (type) {
        case IOS_FD_TUNNEL:
            return bridge->tun_read_fd;
        case IOS_FD_UDP:
            return bridge->udp_read_fd;
        case IOS_FD_MGR:
            return bridge->mgr_read_fd;
        default:
            return 0;
    }
    return 0;
}

static int write_data_to_fd(int fd, const void *data, int len) {
    if (fd > 0) {
        int size = (int)write(fd, data, len);
        printf("write to fd: %d, %d, %d\n", fd, len, size);
        return size;
    }
    return -1;
}

int ios_write_data(void *handle, ios_fd_type type, const void *data, int len) {
    if (handle == NULL) {
        return -1;
    }
    ios_io_bridge *bridge = (ios_io_bridge *)handle;
    int fd = 0;
    if (IOS_FD_TUNNEL == type) {
        fd = bridge->tun_write_fd;
    } else if (IOS_FD_UDP == type) {
        fd = bridge->udp_write_fd;
    } else if (IOS_FD_MGR == type) {
        fd = bridge->mgr_write_fd;
    }
    
    return write_data_to_fd(fd, data, len);
}

int ios_receive_tun_data(void *handle, const void *data, int len) {
    if (handle == NULL) {
        return -1;
    }
    ios_io_bridge *bridge = (ios_io_bridge *)handle;
    return write_data_to_fd(bridge->tun_write_fd, data, len);
}

int ios_receive_udp_data(void *handle, const void *data, int len) {
    if (handle == NULL) {
        return -1;
    }
    ios_io_bridge *bridge = (ios_io_bridge *)handle;
    return write_data_to_fd(bridge->udp_write_fd, data, len);
}

int ios_receive_mgr_data(void *handle, const void *data, int len) {
    if (handle == NULL) {
        return -1;
    }
    ios_io_bridge *bridge = (ios_io_bridge *)handle;
    return write_data_to_fd(bridge->mgr_write_fd, data, len);
}

void ios_destroy_bridge(void *handle) {
    if (handle == 0) {
        return;
    }
    ios_io_bridge *bridge = (ios_io_bridge *)handle;
    deinit_fd(bridge);
    return;
}
