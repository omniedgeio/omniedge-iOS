//
// Created by switchwang(https://github.com/switch-st) on 2018-04-13.
//

#ifndef _EDGE_JNI_H_
#define _EDGE_JNI_H_

#if defined(__ANDROID_NDK__) || defined(__IOS_PLATFORM__)

#ifdef __ANDROID_NDK__
#include <jni.h>
#endif

#include <pthread.h>

#define EDGE_CMD_IPSTR_SIZE 16
#define EDGE_CMD_SUPERNODES_NUM 2
#define EDGE_CMD_SN_HOST_SIZE 48
#define EDGE_CMD_MACNAMSIZ 18
#define EDGE_CMD_COMMUNITY_SIZE 16
#define EDGE_CMD_HOLEPUNCH_INTERVAL 25
#define EDGE_CMD_ENCRYPTION_MODE_SIZE 16

typedef struct n2n_edge_cmd_st
{
    char ip_addr[EDGE_CMD_IPSTR_SIZE];
    char ip_netmask[EDGE_CMD_IPSTR_SIZE];
    char supernodes[EDGE_CMD_SUPERNODES_NUM][EDGE_CMD_SN_HOST_SIZE];
    char community[EDGE_CMD_COMMUNITY_SIZE];
    char* enc_key;
    char* enc_key_file;
    char mac_addr[EDGE_CMD_MACNAMSIZ];
    unsigned int mtu;
    char local_ip[EDGE_CMD_IPSTR_SIZE];
    char gateway_ip[EDGE_CMD_IPSTR_SIZE];
    char encryption_mode[EDGE_CMD_ENCRYPTION_MODE_SIZE];
    unsigned int holepunch_interval;
    int re_resolve_supernode_ip;
    unsigned int local_port;
    int allow_routing;
    int drop_multicast;
    int http_tunnel;
    int trace_vlevel;
    int vpn_fd;
    char* logpath;
#ifdef __IOS_PLATFORM__
    int udp_fd;
    int mgr_fd;
    ssize_t (*sendto_sock)(int fd, const void * buf, size_t len, const char *ip, int port);
    ssize_t (*recvfrom)(int fd, void *buf, size_t len, char *ip, int *ip_len);
    int (*tuntap_write)(unsigned char *buf, int len);
#endif //__IOS_PLATFORM__
    
} n2n_edge_cmd_t;

enum
{
    EDGE_STAT_CONNECTING,
    EDGE_STAT_CONNECTED,
    EDGE_STAT_SUPERNODE_DISCONNECT,
    EDGE_STAT_DISCONNECT,
    EDGE_STAT_FAILED
};

enum
{
    EDGE_TYPE_NONE = -1,
    EDGE_TYPE_V1,
    EDGE_TYPE_V2,
    EDGE_TYPE_V2S
};

typedef struct n2n_edge_status_st {
    pthread_mutex_t mutex;
    n2n_edge_cmd_t cmd;
    pthread_t tid;
#ifdef __ANDROID_NDK__
    JavaVM *jvm;
    jobject jobj_service;
    jclass jcls_status;
    jclass jcls_rs;
#endif
    
    int (*start_edge)(struct n2n_edge_status_st* status);
    int (*stop_edge)(void);
    void (*report_edge_status)(void);

    uint8_t edge_type;
    uint8_t running_status;
} n2n_edge_status_t;

extern n2n_edge_status_t* g_status;

//extern int start_edge_v1(n2n_edge_status_t* status);
//extern int stop_edge_v1(void);
extern int start_edge_v2(n2n_edge_status_t* status);
extern int stop_edge_v2(void);
//extern int start_edge_v2s(n2n_edge_status_t* status);
//extern int stop_edge_v2s(void);
extern void report_edge_status(void);

#endif /* __ANDROID_NDK__ || __IOS_PLATFORM__ */

#endif //_EDGE_ANDROID_H_
