//
// Created by switchwang(https://github.com/switch-st) on 2018-04-14.
//

#ifndef _TUN2TAP_DEFINE_H_
#define _TUN2TAP_DEFINE_H_

#ifdef __IOS_PLATFORM__
#ifdef HTONS
#undef HTONS
#endif //HTONS

#ifdef htons
#undef htons
#endif //htons
#endif //__IOS_PLATFORM__

#define uip_tcp_appstate_t void*
#define UIP_APPCALL()

extern u8_t* uip_buf;

#endif //_TUN2TAP_DEFINE_H_
