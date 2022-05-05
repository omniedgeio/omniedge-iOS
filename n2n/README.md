
# OmniEdge on iOS

# 1. N2N On iOS

There is no tuntap virtual device supported on iOS platform, so 'uip' is introduced here to provide 'tap' device.

Tun device is implementd in NetworkExtension:

```
class PacketTunnelProvider: NEPacketTunnelProvider {
    ...
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
    }
    ...
}
```

## 1.1 Runloop

Because the runloop in n2n is based on either file descriptor of socket, a bridge between async message and fd is necessary on iOS system.

A pipe based bridge is introduced to solve this problem.

> device.fd

a pipe is instroduced here, fd[0] is set to device.fd for select in n2n runloop. if tunnel packets comes from system statck, data will be written to fd[1] and the select will be activated and data can be read from device.fd.

> udp_sock

> udp_mgmt_sock

## 1.2 data transfer

Once data packets received on Tun device, they'd be transfered to remote(by udp socket shown as below).

```
...
/** Send a datagram to a socket defined by a n2n_sock_t */
static ssize_t sendto_sock(int fd, const void * buf,
			   size_t len, const n2n_sock_t * dest) {
  struct sockaddr_in peer_addr;
...
  fill_sockaddr((struct sockaddr *) &peer_addr,
		sizeof(peer_addr),
		dest);

  sent = sendto(fd, buf, len, 0/*flags*/,
		(struct sockaddr *)&peer_addr, sizeof(struct sockaddr_in));
  if(sent < 0) {
      ...
  } else {
      ...
    }
...

}
...

```

send data to supernode or remote peer:

### 1.2.1 send data to supernode

```
//loop up registration info
static void send_register_super(n2n_edge_t * eee,
				const n2n_sock_t * supernode) {
...
sendto_sock(eee->udp_sock, pktbuf, idx, supernode);
...
}

//loop up peer info
static void send_query_peer( n2n_edge_t * eee,
                             const n2n_mac_t dstMac) {
...
sendto_sock( eee->udp_sock, pktbuf, idx, &(eee->supernode) );
...
}

```

### 1.2.2 send data to remote edge

```
/** Send a REGISTER packet to another edge. */
static void send_register(n2n_edge_t * eee,
		   const n2n_sock_t * remote_peer,
		   const n2n_mac_t peer_mac) {
...
sendto_sock(eee->udp_sock, pktbuf, idx, remote_peer);
...
}

/** Send a REGISTER_ACK packet to a peer edge. */
static void send_register_ack(n2n_edge_t * eee,
			      const n2n_sock_t * remote_peer,
			      const n2n_REGISTER_t * reg) {
...
sendto_sock(eee->udp_sock, pktbuf, idx, remote_peer);
...                      
}

/** Send an ecapsulated ethernet PACKET to a destination edge or broadcast MAC
 *  address. */
static int send_packet(n2n_edge_t * eee,
		       n2n_mac_t dstMac,
		       const uint8_t * pktbuf,
		       size_t pktlen) {
}
```

# Reference

https://kean.blog/post/packet-tunnel-provider

