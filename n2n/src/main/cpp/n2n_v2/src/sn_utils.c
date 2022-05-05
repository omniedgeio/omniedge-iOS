#include "n2n.h"
#include "header_encryption.h"

#define HASH_FIND_COMMUNITY(head, name, out) HASH_FIND_STR(head, name, out)

static int try_forward(n2n_sn_t * sss,
		       const struct sn_community *comm,
		       const n2n_common_t * cmn,
		       const n2n_mac_t dstMac,
		       const uint8_t * pktbuf,
		       size_t pktsize);

static ssize_t sendto_sock(n2n_sn_t *sss,
                           const n2n_sock_t *sock,
                           const uint8_t *pktbuf,
                           size_t pktsize);

static int try_broadcast(n2n_sn_t * sss,
		         const struct sn_community *comm,
			 const n2n_common_t * cmn,
			 const n2n_mac_t srcMac,
			 const uint8_t * pktbuf,
			 size_t pktsize);

static uint16_t reg_lifetime(n2n_sn_t *sss);

static int update_edge(n2n_sn_t *sss,
                       const n2n_mac_t edgeMac,
                       struct sn_community *comm,
                       const n2n_sock_t *sender_sock,
                       time_t now);

static int process_mgmt(n2n_sn_t *sss,
                        const struct sockaddr_in *sender_sock,
                        const uint8_t *mgmt_buf,
                        size_t mgmt_size,
                        time_t now);

static int process_udp(n2n_sn_t *sss,
                       const struct sockaddr_in *sender_sock,
                       uint8_t *udp_buf,
                       size_t udp_size,
                       time_t now);

static int try_forward(n2n_sn_t * sss,
		       const struct sn_community *comm,
		       const n2n_common_t * cmn,
		       const n2n_mac_t dstMac,
		       const uint8_t * pktbuf,
		       size_t pktsize)
{
  struct peer_info *  scan;
  macstr_t            mac_buf;
  n2n_sock_str_t      sockbuf;

  HASH_FIND_PEER(comm->edges, dstMac, scan);

  if(NULL != scan)
    {
      int data_sent_len;
      data_sent_len = sendto_sock(sss, &(scan->sock), pktbuf, pktsize);

      if(data_sent_len == pktsize)
        {
	  ++(sss->stats.fwd);
	  traceEvent(TRACE_DEBUG, "unicast %lu to [%s] %s",
		     pktsize,
		     sock_to_cstr(sockbuf, &(scan->sock)),
		     macaddr_str(mac_buf, scan->mac_addr));
        }
      else
        {
	  ++(sss->stats.errors);
	  traceEvent(TRACE_ERROR, "unicast %lu to [%s] %s FAILED (%d: %s)",
		     pktsize,
		     sock_to_cstr(sockbuf, &(scan->sock)),
		     macaddr_str(mac_buf, scan->mac_addr),
		     errno, strerror(errno));
        }
    }
  else
    {
      traceEvent(TRACE_DEBUG, "try_forward unknown MAC");

      /* Not a known MAC so drop. */
      return(-2);
    }

  return(0);
}

/** Send a datagram to the destination embodied in a n2n_sock_t.
 *
 *  @return -1 on error otherwise number of bytes sent
 */
static ssize_t sendto_sock(n2n_sn_t *sss,
                           const n2n_sock_t *sock,
                           const uint8_t *pktbuf,
                           size_t pktsize)
{
    n2n_sock_str_t sockbuf;

    if (AF_INET == sock->family)
    {
        struct sockaddr_in udpsock;

        udpsock.sin_family = AF_INET;
        udpsock.sin_port = htons(sock->port);
        memcpy(&(udpsock.sin_addr.s_addr), &(sock->addr.v4), IPV4_SIZE);

        traceEvent(TRACE_DEBUG, "sendto_sock %lu to [%s]",
                   pktsize,
                   sock_to_cstr(sockbuf, sock));

        return sendto(sss->sock, pktbuf, pktsize, 0,
                      (const struct sockaddr *)&udpsock, sizeof(struct sockaddr_in));
    }
    else
    {
        /* AF_INET6 not implemented */
        errno = EAFNOSUPPORT;
        return -1;
    }
}

/** Try and broadcast a message to all edges in the community.
 *
 *  This will send the exact same datagram to zero or more edges registered to
 *  the supernode.
 */
static int try_broadcast(n2n_sn_t * sss,
                         const struct sn_community *comm,
			 const n2n_common_t * cmn,
			 const n2n_mac_t srcMac,
			 const uint8_t * pktbuf,
			 size_t pktsize)
{
  struct peer_info *scan, *tmp;
  macstr_t            mac_buf;
  n2n_sock_str_t      sockbuf;

  traceEvent(TRACE_DEBUG, "try_broadcast");

  HASH_ITER(hh, comm->edges, scan, tmp) {
    if(memcmp(srcMac, scan->mac_addr, sizeof(n2n_mac_t)) != 0) {
      /* REVISIT: exclude if the destination socket is where the packet came from. */
      int data_sent_len;

      data_sent_len = sendto_sock(sss, &(scan->sock), pktbuf, pktsize);

      if(data_sent_len != pktsize)
      {
        ++(sss->stats.errors);
        traceEvent(TRACE_WARNING, "multicast %lu to [%s] %s failed %s",
  		   pktsize,
		   sock_to_cstr(sockbuf, &(scan->sock)),
		   macaddr_str(mac_buf, scan->mac_addr),
		   strerror(errno));
      }
      else
      {
        ++(sss->stats.broadcast);
        traceEvent(TRACE_DEBUG, "multicast %lu to [%s] %s",
	           pktsize,
		   sock_to_cstr(sockbuf, &(scan->sock)),
		   macaddr_str(mac_buf, scan->mac_addr));
      }
    }
  }
  return 0;
}


/** Initialise the supernode structure */
int sn_init(n2n_sn_t *sss)
{
#ifdef WIN32
    initWin32();
#endif

    pearson_hash_init();

    memset(sss, 0, sizeof(n2n_sn_t));

    sss->daemon = 1; /* By defult run as a daemon. */
    sss->lport = N2N_SN_LPORT_DEFAULT;
    sss->sock = -1;
    sss->mgmt_sock = -1;

    return 0; /* OK */
}

/** Deinitialise the supernode structure and deallocate any memory owned by
 *  it. */
void sn_term(n2n_sn_t *sss)
{
    struct sn_community *community, *tmp;

    if (sss->sock >= 0)
    {
        closesocket(sss->sock);
    }
    sss->sock = -1;

    if (sss->mgmt_sock >= 0)
    {
        closesocket(sss->mgmt_sock);
    }
    sss->mgmt_sock = -1;

    HASH_ITER(hh, sss->communities, community, tmp)
    {
        clear_peer_list(&community->edges);
        if (NULL != community->header_encryption_ctx)
          free (community->header_encryption_ctx);
        HASH_DEL(sss->communities, community);
        free(community);
    }
}

/** Determine the appropriate lifetime for new registrations.
 *
 *  If the supernode has been put into a pre-shutdown phase then this lifetime
 *  should not allow registrations to continue beyond the shutdown point.
 */
static uint16_t reg_lifetime(n2n_sn_t *sss)
{
    /* NOTE: UDP firewalls usually have a 30 seconds timeout */
    return 15;
}

/** Update the edge table with the details of the edge which contacted the
 *  supernode. */
static int update_edge(n2n_sn_t *sss,
                       const n2n_mac_t edgeMac,
                       struct sn_community *comm,
                       const n2n_sock_t *sender_sock,
                       time_t now)
{
    macstr_t mac_buf;
    n2n_sock_str_t sockbuf;
    struct peer_info *scan;

    traceEvent(TRACE_DEBUG, "update_edge for %s [%s]",
               macaddr_str(mac_buf, edgeMac),
               sock_to_cstr(sockbuf, sender_sock));

    HASH_FIND_PEER(comm->edges, edgeMac, scan);

    if (NULL == scan)
    {
        /* Not known */

        scan = (struct peer_info *)calloc(1,
                                          sizeof(struct peer_info)); /* deallocated in purge_expired_registrations */

        memcpy(&(scan->mac_addr), edgeMac, sizeof(n2n_mac_t));
        memcpy(&(scan->sock), sender_sock, sizeof(n2n_sock_t));

        HASH_ADD_PEER(comm->edges, scan);

        traceEvent(TRACE_INFO, "update_edge created   %s ==> %s",
                   macaddr_str(mac_buf, edgeMac),
                   sock_to_cstr(sockbuf, sender_sock));
    }
    else
    {
        /* Known */
        if (!sock_equal(sender_sock, &(scan->sock)))
        {
            memcpy(&(scan->sock), sender_sock, sizeof(n2n_sock_t));

            traceEvent(TRACE_INFO, "update_edge updated   %s ==> %s",
                       macaddr_str(mac_buf, edgeMac),
                       sock_to_cstr(sockbuf, sender_sock));
        }
        else
        {
            traceEvent(TRACE_DEBUG, "update_edge unchanged %s ==> %s",
                       macaddr_str(mac_buf, edgeMac),
                       sock_to_cstr(sockbuf, sender_sock));
        }
    }

    scan->last_seen = now;
    return 0;
}

static int process_mgmt(n2n_sn_t *sss,
                        const struct sockaddr_in *sender_sock,
                        const uint8_t *mgmt_buf,
                        size_t mgmt_size,
                        time_t now)
{
    char resbuf[N2N_SN_PKTBUF_SIZE];
    size_t ressize = 0;
    uint32_t num_edges = 0;
    ssize_t r;
    struct sn_community *community, *tmp;
    struct peer_info * peer, *tmpPeer;
    macstr_t mac_buf;

    traceEvent(TRACE_DEBUG, "process_mgmt");

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "----------------\n");

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "uptime    %lu\n", (now - sss->start_time));

    HASH_ITER(hh, sss->communities, community, tmp)
    {
        num_edges += HASH_COUNT(community->edges);
    }

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "edges     %u\n",
                        num_edges);

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "errors    %u\n",
                        (unsigned int)sss->stats.errors);

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "reg_sup   %u\n",
                        (unsigned int)sss->stats.reg_super);

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "reg_nak   %u\n",
                        (unsigned int)sss->stats.reg_super_nak);

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "fwd       %u\n",
                        (unsigned int)sss->stats.fwd);

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "broadcast %u\n",
                        (unsigned int)sss->stats.broadcast);

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "last fwd  %lu sec ago\n",
                        (long unsigned int)(now - sss->stats.last_fwd));

    ressize += snprintf(resbuf + ressize, N2N_SN_PKTBUF_SIZE - ressize,
                        "last reg  %lu sec ago\n",
                        (long unsigned int)(now - sss->stats.last_reg_super));

    ressize += snprintf(resbuf+ressize, N2N_SN_PKTBUF_SIZE-ressize,
                        "cur_cmnts");
    HASH_ITER(hh, sss->communities, community, tmp) {
      ressize += snprintf(resbuf+ressize, N2N_SN_PKTBUF_SIZE-ressize,
                          " [%s]",
                          community->community);
      HASH_ITER(hh, community->edges, peer, tmpPeer) {
        ressize += snprintf(resbuf+ressize, N2N_SN_PKTBUF_SIZE-ressize,
                            " {%s}",
                            macaddr_str(mac_buf, peer->mac_addr));
      }
    }
    ressize += snprintf(resbuf+ressize, N2N_SN_PKTBUF_SIZE-ressize,
                        "\n");

    r = sendto(sss->mgmt_sock, resbuf, ressize, 0 /*flags*/,
               (struct sockaddr *)sender_sock, sizeof(struct sockaddr_in));

    if (r <= 0)
    {
        ++(sss->stats.errors);
        traceEvent(TRACE_ERROR, "process_mgmt : sendto failed. %s", strerror(errno));
    }

    return 0;
}

/** Examine a datagram and determine what to do with it.
 *
 */
static int process_udp(n2n_sn_t * sss,
		       const struct sockaddr_in * sender_sock,
		       uint8_t * udp_buf,
		       size_t udp_size,
		       time_t now)
{
  n2n_common_t        cmn; /* common fields in the packet header */
  size_t              rem;
  size_t              idx;
  size_t              msg_type;
  uint8_t             from_supernode;
  macstr_t            mac_buf;
  macstr_t            mac_buf2;
  n2n_sock_str_t      sockbuf;
  char                buf[32];
  struct sn_community *comm, *tmp;

  traceEvent(TRACE_DEBUG, "Processing incoming UDP packet [len: %lu][sender: %s:%u]",
	     udp_size, intoa(ntohl(sender_sock->sin_addr.s_addr), buf, sizeof(buf)),
	     ntohs(sender_sock->sin_port));

  /* check if header is unenrypted. the following check is around 99.99962 percent reliable.
   * it heavily relies on the structure of packet's common part
   * changes to wire.c:encode/decode_common need to go together with this code */
  if (udp_size < 20) {
    traceEvent(TRACE_DEBUG, "process_udp dropped a packet too short to be valid.");
    return -1;
  }
  if ( (udp_buf[19] == (uint8_t)0x00) // null terminated community name
       && (udp_buf[00] == N2N_PKT_VERSION) // correct packet version
       && ((be16toh (*(uint16_t*)&(udp_buf[02])) & N2N_FLAGS_TYPE_MASK ) <= MSG_TYPE_MAX_TYPE  ) // message type
       && ( be16toh (*(uint16_t*)&(udp_buf[02])) < N2N_FLAGS_OPTIONS) // flags
       ) {
    /* most probably unencrypted */
    /* make sure, no downgrading happens here and no unencrypted packets can be
     * injected in a community which definitely deals with encrypted headers */
    HASH_FIND_COMMUNITY(sss->communities, (char *)&udp_buf[04], comm);
    if (comm) {
      if (comm->header_encryption == HEADER_ENCRYPTION_ENABLED) {
        traceEvent(TRACE_DEBUG, "process_udp dropped a packet with unencrypted header "
                                "addressed to community '%s' which uses encrypted headers.",
                                 comm->community);
        return -1;
      }
      if (comm->header_encryption == HEADER_ENCRYPTION_UNKNOWN) {
	traceEvent (TRACE_INFO, "process_udp locked community '%s' to using "
                                "unencrypted headers.", comm->community);
        /* set 'no encryption' in case it is not set yet */
        comm->header_encryption = HEADER_ENCRYPTION_NONE;
        comm->header_encryption_ctx = NULL;
      }
    }
  } else {
    /* most probably encrypted */
    /* cycle through the known communities (as keys) to eventually decrypt */
    uint32_t ret = 0;
    HASH_ITER (hh, sss->communities, comm, tmp) {
      /* skip the definitely unencrypted communities */
      if (comm->header_encryption == HEADER_ENCRYPTION_NONE)
        continue;
      uint16_t checksum = 0;
      if ( (ret = packet_header_decrypt (udp_buf, udp_size, comm->community, comm->header_encryption_ctx,
                                         comm->header_iv_ctx, &checksum)) ) {
       if (checksum != pearson_hash_16 (udp_buf, udp_size)) {
         traceEvent(TRACE_DEBUG, "process_udp dropped packet due to checksum error.");
         return -1;
        }
        if (comm->header_encryption == HEADER_ENCRYPTION_UNKNOWN) {
	  traceEvent (TRACE_INFO, "process_udp locked community '%s' to using "
                                  "encrypted headers.", comm->community);
          /* set 'encrypted' in case it is not set yet */
          comm->header_encryption = HEADER_ENCRYPTION_ENABLED;
        }
	// no need to test further communities
        break;
      }
    }
    if (!ret) {
      // no matching key/community
      traceEvent(TRACE_DEBUG, "process_udp dropped a packet with seemingly encrypted header "
			      "for which no matching community which uses encrypted headers was found.");
      return -1;
    }
  }

  /* Use decode_common() to determine the kind of packet then process it:
   *
   * REGISTER_SUPER adds an edge and generate a return REGISTER_SUPER_ACK
   *
   * REGISTER, REGISTER_ACK and PACKET messages are forwarded to their
   * destination edge. If the destination is not known then PACKETs are
   * broadcast.
   */

  rem = udp_size; /* Counts down bytes of packet to protect against buffer overruns. */
  idx = 0; /* marches through packet header as parts are decoded. */
  if(decode_common(&cmn, udp_buf, &rem, &idx) < 0) {
    traceEvent(TRACE_ERROR, "Failed to decode common section");
    return -1; /* failed to decode packet */
  }

  msg_type = cmn.pc; /* packet code */
  from_supernode= cmn.flags & N2N_FLAGS_FROM_SUPERNODE;

  if(cmn.ttl < 1) {
    traceEvent(TRACE_WARNING, "Expired TTL");
    return 0; /* Don't process further */
  }

  --(cmn.ttl); /* The value copied into all forwarded packets. */

  switch(msg_type) {
  case MSG_TYPE_PACKET:
  {
    /* PACKET from one edge to another edge via supernode. */

    /* pkt will be modified in place and recoded to an output of potentially
     * different size due to addition of the socket.*/
    n2n_PACKET_t                    pkt;
    n2n_common_t                    cmn2;
    uint8_t                         encbuf[N2N_SN_PKTBUF_SIZE];
    size_t                          encx=0;
    int                             unicast; /* non-zero if unicast */
    uint8_t *                       rec_buf; /* either udp_buf or encbuf */

    if(!comm) {
      traceEvent(TRACE_DEBUG, "process_udp PACKET with unknown community %s", cmn.community);
      return -1;
    }

    sss->stats.last_fwd=now;
    decode_PACKET(&pkt, &cmn, udp_buf, &rem, &idx);

    unicast = (0 == is_multi_broadcast(pkt.dstMac));

    traceEvent(TRACE_DEBUG, "RX PACKET (%s) %s -> %s %s",
	       (unicast?"unicast":"multicast"),
	       macaddr_str(mac_buf, pkt.srcMac),
	       macaddr_str(mac_buf2, pkt.dstMac),
	       (from_supernode?"from sn":"local"));

    if(!from_supernode) {
      memcpy(&cmn2, &cmn, sizeof(n2n_common_t));

      /* We are going to add socket even if it was not there before */
      cmn2.flags |= N2N_FLAGS_SOCKET | N2N_FLAGS_FROM_SUPERNODE;

      pkt.sock.family = AF_INET;
      pkt.sock.port = ntohs(sender_sock->sin_port);
      memcpy(pkt.sock.addr.v4, &(sender_sock->sin_addr.s_addr), IPV4_SIZE);

      rec_buf = encbuf;

      /* Re-encode the header. */
      encode_PACKET(encbuf, &encx, &cmn2, &pkt);
      uint16_t oldEncx = encx;

      /* Copy the original payload unchanged */
      encode_buf(encbuf, &encx, (udp_buf + idx), (udp_size - idx));

      if (comm->header_encryption == HEADER_ENCRYPTION_ENABLED)
        packet_header_encrypt (rec_buf, oldEncx, comm->header_encryption_ctx,
                                                 comm->header_iv_ctx, pearson_hash_16 (rec_buf, encx));

    } else {
      /* Already from a supernode. Nothing to modify, just pass to
       * destination. */

      traceEvent(TRACE_DEBUG, "Rx PACKET fwd unmodified");

      rec_buf = udp_buf;
      encx = udp_size;

      if (comm->header_encryption == HEADER_ENCRYPTION_ENABLED)
        packet_header_encrypt (rec_buf, idx, comm->header_encryption_ctx,
                                             comm->header_iv_ctx, pearson_hash_16 (rec_buf, udp_size));
    }

    /* Common section to forward the final product. */
    if(unicast)
      try_forward(sss, comm, &cmn, pkt.dstMac, rec_buf, encx);
    else
      try_broadcast(sss, comm, &cmn, pkt.srcMac, rec_buf, encx);
    break;
  }
  case MSG_TYPE_REGISTER:
  {
    /* Forwarding a REGISTER from one edge to the next */

    n2n_REGISTER_t                  reg;
    n2n_common_t                    cmn2;
    uint8_t                         encbuf[N2N_SN_PKTBUF_SIZE];
    size_t                          encx=0;
    int                             unicast; /* non-zero if unicast */
    uint8_t *                       rec_buf; /* either udp_buf or encbuf */

    if(!comm) {
      traceEvent(TRACE_DEBUG, "process_udp REGISTER from unknown community %s", cmn.community);
      return -1;
    }

    sss->stats.last_fwd=now;
    decode_REGISTER(&reg, &cmn, udp_buf, &rem, &idx);

    unicast = (0 == is_multi_broadcast(reg.dstMac));

    if(unicast) {
      traceEvent(TRACE_DEBUG, "Rx REGISTER %s -> %s %s",
		 macaddr_str(mac_buf, reg.srcMac),
		 macaddr_str(mac_buf2, reg.dstMac),
		 ((cmn.flags & N2N_FLAGS_FROM_SUPERNODE)?"from sn":"local"));

      if(0 == (cmn.flags & N2N_FLAGS_FROM_SUPERNODE)) {
	memcpy(&cmn2, &cmn, sizeof(n2n_common_t));

	/* We are going to add socket even if it was not there before */
	cmn2.flags |= N2N_FLAGS_SOCKET | N2N_FLAGS_FROM_SUPERNODE;

	reg.sock.family = AF_INET;
	reg.sock.port = ntohs(sender_sock->sin_port);
	memcpy(reg.sock.addr.v4, &(sender_sock->sin_addr.s_addr), IPV4_SIZE);

	rec_buf = encbuf;

	/* Re-encode the header. */
	encode_REGISTER(encbuf, &encx, &cmn2, &reg);
      } else {
	/* Already from a supernode. Nothing to modify, just pass to
	 * destination. */

	rec_buf = udp_buf;
	encx = udp_size;
      }

      if (comm->header_encryption == HEADER_ENCRYPTION_ENABLED)
        packet_header_encrypt (rec_buf, encx, comm->header_encryption_ctx,
                                             comm->header_iv_ctx, pearson_hash_16 (rec_buf, encx));

      try_forward(sss, comm, &cmn, reg.dstMac, rec_buf, encx); /* unicast only */
    } else
      traceEvent(TRACE_ERROR, "Rx REGISTER with multicast destination");
    break;
  }
  case MSG_TYPE_REGISTER_ACK:
    traceEvent(TRACE_DEBUG, "Rx REGISTER_ACK (NOT IMPLEMENTED) SHould not be via supernode");
    break;
  case MSG_TYPE_REGISTER_SUPER:
  {
    n2n_REGISTER_SUPER_t            reg;
    n2n_REGISTER_SUPER_ACK_t        ack;
    n2n_common_t                    cmn2;
    uint8_t                         ackbuf[N2N_SN_PKTBUF_SIZE];
    size_t                          encx=0;

    /* Edge requesting registration with us.  */
    sss->stats.last_reg_super=now;
    ++(sss->stats.reg_super);
    decode_REGISTER_SUPER(&reg, &cmn, udp_buf, &rem, &idx);

    /*
      Before we move any further, we need to check if the requested
      community is allowed by the supernode. In case it is not we do
      not report any message back to the edge to hide the supernode
      existance (better from the security standpoint)
    */
    if(!comm && !sss->lock_communities) {
      comm = calloc(1, sizeof(struct sn_community));

      if(comm) {
	strncpy(comm->community, (char*)cmn.community, N2N_COMMUNITY_SIZE-1);
	comm->community[N2N_COMMUNITY_SIZE-1] = '\0';
        /* new communities introduced by REGISTERs could not have had encrypted header */
        comm->header_encryption = HEADER_ENCRYPTION_NONE;
	comm->header_encryption_ctx = NULL;

	HASH_ADD_STR(sss->communities, community, comm);

	traceEvent(TRACE_INFO, "New community: %s", comm->community);
      }
    }

    if(comm) {
      cmn2.ttl = N2N_DEFAULT_TTL;
      cmn2.pc = n2n_register_super_ack;
      cmn2.flags = N2N_FLAGS_SOCKET | N2N_FLAGS_FROM_SUPERNODE;
      memcpy(cmn2.community, cmn.community, sizeof(n2n_community_t));

      memcpy(&(ack.cookie), &(reg.cookie), sizeof(n2n_cookie_t));
      memcpy(ack.edgeMac, reg.edgeMac, sizeof(n2n_mac_t));
      ack.lifetime = reg_lifetime(sss);

      ack.sock.family = AF_INET;
      ack.sock.port = ntohs(sender_sock->sin_port);
      memcpy(ack.sock.addr.v4, &(sender_sock->sin_addr.s_addr), IPV4_SIZE);

      ack.num_sn=0; /* No backup */
      memset(&(ack.sn_bak), 0, sizeof(n2n_sock_t));

      traceEvent(TRACE_DEBUG, "Rx REGISTER_SUPER for %s [%s]",
		 macaddr_str(mac_buf, reg.edgeMac),
		 sock_to_cstr(sockbuf, &(ack.sock)));

      update_edge(sss, reg.edgeMac, comm, &(ack.sock), now);

      encode_REGISTER_SUPER_ACK(ackbuf, &encx, &cmn2, &ack);

      if (comm->header_encryption == HEADER_ENCRYPTION_ENABLED)
        packet_header_encrypt (ackbuf, encx, comm->header_encryption_ctx,
                                             comm->header_iv_ctx, pearson_hash_16 (ackbuf, encx));

      sendto(sss->sock, ackbuf, encx, 0,
	     (struct sockaddr *)sender_sock, sizeof(struct sockaddr_in));

      traceEvent(TRACE_DEBUG, "Tx REGISTER_SUPER_ACK for %s [%s]",
		 macaddr_str(mac_buf, reg.edgeMac),
		 sock_to_cstr(sockbuf, &(ack.sock)));
    } else
      traceEvent(TRACE_INFO, "Discarded registration: unallowed community '%s'",
		 (char*)cmn.community);
    break;
  }
  case MSG_TYPE_QUERY_PEER: {
    n2n_QUERY_PEER_t query;
    uint8_t encbuf[N2N_SN_PKTBUF_SIZE];
    size_t encx=0;
    n2n_common_t cmn2;
    n2n_PEER_INFO_t pi;

    if(!comm) {
      traceEvent(TRACE_DEBUG, "process_udp QUERY_PEER from unknown community %s", cmn.community);
      return -1;
    }

    decode_QUERY_PEER( &query, &cmn, udp_buf, &rem, &idx );

    traceEvent( TRACE_DEBUG, "Rx QUERY_PEER from %s for %s",
                macaddr_str( mac_buf,  query.srcMac ),
                macaddr_str( mac_buf2, query.targetMac ) );

    struct peer_info *scan;
    HASH_FIND_PEER(comm->edges, query.targetMac, scan);

    if (scan) {
      cmn2.ttl = N2N_DEFAULT_TTL;
      cmn2.pc = n2n_peer_info;
      cmn2.flags = N2N_FLAGS_FROM_SUPERNODE;
      memcpy( cmn2.community, cmn.community, sizeof(n2n_community_t) );

      pi.aflags = 0;
      memcpy( pi.mac, query.targetMac, sizeof(n2n_mac_t) );
      pi.sock = scan->sock;

      encode_PEER_INFO( encbuf, &encx, &cmn2, &pi );

      if (comm->header_encryption == HEADER_ENCRYPTION_ENABLED)
        packet_header_encrypt (encbuf, encx, comm->header_encryption_ctx,
                                             comm->header_iv_ctx, pearson_hash_16 (encbuf, encx));

      sendto( sss->sock, encbuf, encx, 0,
	      (struct sockaddr *)sender_sock, sizeof(struct sockaddr_in) );

      traceEvent( TRACE_DEBUG, "Tx PEER_INFO to %s",
		                macaddr_str( mac_buf, query.srcMac ) );
    } else {
      traceEvent( TRACE_DEBUG, "Ignoring QUERY_PEER for unknown edge %s",
	                        macaddr_str( mac_buf, query.targetMac ) );
    }

  break;
  }
  default:
    /* Not a known message type */
    traceEvent(TRACE_WARNING, "Unable to handle packet type %d: ignored", (signed int)msg_type);
  } /* switch(msg_type) */

  return 0;
}

/** Long lived processing entry point. Split out from main to simply
 *  daemonisation on some platforms. */
int run_sn_loop(n2n_sn_t *sss, int *keep_running)
{
    uint8_t pktbuf[N2N_SN_PKTBUF_SIZE];
    time_t last_purge_edges = 0;
    struct sn_community *comm, *tmp;

    sss->start_time = time(NULL);

    while (*keep_running)
    {
        int rc;
        ssize_t bread;
        int max_sock;
        fd_set socket_mask;
        struct timeval wait_time;
        time_t now = 0;

        FD_ZERO(&socket_mask);
        max_sock = MAX(sss->sock, sss->mgmt_sock);

        FD_SET(sss->sock, &socket_mask);
        FD_SET(sss->mgmt_sock, &socket_mask);

        wait_time.tv_sec = 10;
        wait_time.tv_usec = 0;
        rc = select(max_sock + 1, &socket_mask, NULL, NULL, &wait_time);

        now = time(NULL);

        if (rc > 0)
        {
            if (FD_ISSET(sss->sock, &socket_mask))
            {
                struct sockaddr_in sender_sock;
                socklen_t i;

                i = sizeof(sender_sock);
                bread = recvfrom(sss->sock, pktbuf, N2N_SN_PKTBUF_SIZE, 0 /*flags*/,
                                 (struct sockaddr *)&sender_sock, (socklen_t *)&i);

                if ((bread < 0)
#ifdef WIN32
                    && (WSAGetLastError() != WSAECONNRESET)
#endif
                )
                {
                    /* For UDP bread of zero just means no data (unlike TCP). */
                    /* The fd is no good now. Maybe we lost our interface. */
                    traceEvent(TRACE_ERROR, "recvfrom() failed %d errno %d (%s)", bread, errno, strerror(errno));
#ifdef WIN32
                    traceEvent(TRACE_ERROR, "WSAGetLastError(): %u", WSAGetLastError());
#endif
                    *keep_running = 0;
                    break;
                }

                /* We have a datagram to process */
                if (bread > 0)
                {
                    /* And the datagram has data (not just a header) */
                    process_udp(sss, &sender_sock, pktbuf, bread, now);
                }
            }

            if (FD_ISSET(sss->mgmt_sock, &socket_mask))
            {
                struct sockaddr_in sender_sock;
                size_t i;

                i = sizeof(sender_sock);
                bread = recvfrom(sss->mgmt_sock, pktbuf, N2N_SN_PKTBUF_SIZE, 0 /*flags*/,
                                 (struct sockaddr *)&sender_sock, (socklen_t *)&i);

                if (bread <= 0)
                {
                    traceEvent(TRACE_ERROR, "recvfrom() failed %d errno %d (%s)", bread, errno, strerror(errno));
                    *keep_running = 0;
                    break;
                }

                /* We have a datagram to process */
                process_mgmt(sss, &sender_sock, pktbuf, bread, now);
            }
        }
        else
        {
            traceEvent(TRACE_DEBUG, "timeout");
        }

        HASH_ITER(hh, sss->communities, comm, tmp)
        {
            purge_expired_registrations(&comm->edges, &last_purge_edges);

            if ((comm->edges == NULL) && (!sss->lock_communities))
            {
                traceEvent(TRACE_INFO, "Purging idle community %s", comm->community);
                if (NULL != comm->header_encryption_ctx)
		    /* this should not happen as no 'locked' and thus only communities w/o encrypted header here */
                    free (comm->header_encryption_ctx);
		HASH_DEL(sss->communities, comm);
                free(comm);
            }
        }

    } /* while */

    sn_term(sss);

    return 0;
}
