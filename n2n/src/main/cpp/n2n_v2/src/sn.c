/**
 * (C) 2007-20 - ntop.org and contributors
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

/* Supernode for n2n-2.x */

#include "n2n.h"
#include "header_encryption.h"





static n2n_sn_t sss_node;



/** Load the list of allowed communities. Existing/previous ones will be removed
 *
 */
static int load_allowed_sn_community(n2n_sn_t *sss, char *path) {
  char buffer[4096], *line;
  FILE *fd = fopen(path, "r");
  struct sn_community *s, *tmp;
  uint32_t num_communities = 0;

  if(fd == NULL) {
    traceEvent(TRACE_WARNING, "File %s not found", path);
    return -1;
  }

  HASH_ITER(hh, sss->communities, s, tmp) {
    HASH_DEL(sss->communities, s);
    if (NULL != s->header_encryption_ctx)
      free (s->header_encryption_ctx);
    free(s);
  }

  while((line = fgets(buffer, sizeof(buffer), fd)) != NULL) {
    int len = strlen(line);

    if((len < 2) || line[0] == '#')
      continue;

    len--;
    while(len > 0) {
      if((line[len] == '\n') || (line[len] == '\r')) {
	line[len] = '\0';
	len--;
      } else
	break;
    }

    s = (struct sn_community*)calloc(1,sizeof(struct sn_community));

    if(s != NULL) {
      strncpy((char*)s->community, line, N2N_COMMUNITY_SIZE-1);
      s->community[N2N_COMMUNITY_SIZE-1] = '\0';
      /* we do not know if header encryption is used in this community,
       * first packet will show. just in case, setup the key.           */
      s->header_encryption = HEADER_ENCRYPTION_UNKNOWN;
      packet_header_setup_key (s->community, &(s->header_encryption_ctx), &(s->header_iv_ctx));
      HASH_ADD_STR(sss->communities, community, s);

      num_communities++;
      traceEvent(TRACE_INFO, "Added allowed community '%s' [total: %u]",
		 (char*)s->community, num_communities);
    }
  }

  fclose(fd);

  traceEvent(TRACE_NORMAL, "Loaded %u communities from %s",
	     num_communities, path);

  /* No new communities will be allowed */
  sss->lock_communities = 1;

  return(0);
}


/* *************************************************** */

/** Help message to print if the command line arguments are not valid. */
static void help() {
  print_n2n_version();

  printf("supernode <config file> (see supernode.conf)\n"
	 "or\n"
	 );
  printf("supernode ");
  printf("-l <lport> ");
  printf("-c <path> ");
#if defined(N2N_HAVE_DAEMON)
  printf("[-f] ");
#endif
  printf("[-v] ");
  printf("\n\n");

  printf("-l <lport>\tSet UDP main listen port to <lport>\n");
  printf("-c <path>\tFile containing the allowed communities.\n");
#if defined(N2N_HAVE_DAEMON)
  printf("-f        \tRun in foreground.\n");
#endif /* #if defined(N2N_HAVE_DAEMON) */
  printf("-v        \tIncrease verbosity. Can be used multiple times.\n");
  printf("-h        \tThis help message.\n");
  printf("\n");

  exit(1);
}


/* *************************************************** */

static int setOption(int optkey, char *_optarg, n2n_sn_t *sss) {
  //traceEvent(TRACE_NORMAL, "Option %c = %s", optkey, _optarg ? _optarg : "");

  switch(optkey) {
  case 'l': /* local-port */
    sss->lport = atoi(_optarg);
    break;

  case 'c': /* community file */
    load_allowed_sn_community(sss, _optarg);
    break;

  case 'f': /* foreground */
    sss->daemon = 0;
    break;

  case 'h': /* help */
    help();
    break;

  case 'v': /* verbose */
    setTraceLevel(getTraceLevel() + 1);
    break;

  default:
    traceEvent(TRACE_WARNING, "Unknown option -%c: Ignored.", (char)optkey);
    return(-1);
  }

  return(0);
}

/* *********************************************** */

static const struct option long_options[] = {
  { "communities",     required_argument, NULL, 'c' },
  { "foreground",      no_argument,       NULL, 'f' },
  { "local-port",      required_argument, NULL, 'l' },
  { "help"   ,         no_argument,       NULL, 'h' },
  { "verbose",         no_argument,       NULL, 'v' },
  { NULL,              0,                 NULL,  0  }
};

/* *************************************************** */

/* read command line options */
static int loadFromCLI(int argc, char * const argv[], n2n_sn_t *sss) {
  u_char c;

  while((c = getopt_long(argc, argv, "fl:c:vh",
			 long_options, NULL)) != '?') {
    if(c == 255) break;
    setOption(c, optarg, sss);
  }

  return 0;
}

/* *************************************************** */

static char *trim(char *s) {
  char *end;

  while(isspace(s[0]) || (s[0] == '"') || (s[0] == '\''))
    s++;

  if(s[0] == 0) return s;

  end = &s[strlen(s) - 1];
  while(end > s
	&& (isspace(end[0])|| (end[0] == '"') || (end[0] == '\'')))
    end--;
  end[1] = 0;

  return s;
}

/* *************************************************** */

/* parse the configuration file */
static int loadFromFile(const char *path, n2n_sn_t *sss) {
  char buffer[4096], *line, *key, *value;
  u_int line_len, opt_name_len;
  FILE *fd;
  const struct option *opt;

  fd = fopen(path, "r");

  if(fd == NULL) {
    traceEvent(TRACE_WARNING, "Config file %s not found", path);
    return -1;
  }

  while((line = fgets(buffer, sizeof(buffer), fd)) != NULL) {

    line = trim(line);
    value = NULL;

    if((line_len = strlen(line)) < 2 || line[0] == '#')
      continue;

    if(!strncmp(line, "--", 2)) { /* long opt */
      key = &line[2], line_len -= 2;

      opt = long_options;
      while(opt->name != NULL) {
	opt_name_len = strlen(opt->name);

	if(!strncmp(key, opt->name, opt_name_len)
	   && (line_len <= opt_name_len
	       || key[opt_name_len] == '\0'
	       || key[opt_name_len] == ' '
	       || key[opt_name_len] == '=')) {
	  if(line_len > opt_name_len)	  key[opt_name_len] = '\0';
	  if(line_len > opt_name_len + 1) value = trim(&key[opt_name_len + 1]);

	  // traceEvent(TRACE_NORMAL, "long key: %s value: %s", key, value);
	  setOption(opt->val, value, sss);
	  break;
	}

	opt++;
      }
    } else if(line[0] == '-') { /* short opt */
      key = &line[1], line_len--;
      if(line_len > 1) key[1] = '\0';
      if(line_len > 2) value = trim(&key[2]);

      // traceEvent(TRACE_NORMAL, "key: %c value: %s", key[0], value);
      setOption(key[0], value, sss);
    } else {
      traceEvent(TRACE_WARNING, "Skipping unrecognized line: %s", line);
      continue;
    }
  }

  fclose(fd);

  return 0;
}

/* *************************************************** */

#ifdef __linux__
static void dump_registrations(int signo) {
  struct sn_community *comm, *ctmp;
  struct peer_info *list, *tmp;
  char buf[32];
  time_t now = time(NULL);
  u_int num = 0;

  traceEvent(TRACE_NORMAL, "====================================");

  HASH_ITER(hh, sss_node.communities, comm, ctmp) {
    traceEvent(TRACE_NORMAL, "Dumping community: %s", comm->community);

    HASH_ITER(hh, comm->edges, list, tmp) {
      if(list->sock.family == AF_INET)
	traceEvent(TRACE_NORMAL, "[id: %u][MAC: %s][edge: %u.%u.%u.%u:%u][last seen: %u sec ago]",
		   ++num, macaddr_str(buf, list->mac_addr),
		   list->sock.addr.v4[0], list->sock.addr.v4[1], list->sock.addr.v4[2], list->sock.addr.v4[3],
		   list->sock.port,
		   now-list->last_seen);
      else
	traceEvent(TRACE_NORMAL, "[id: %u][MAC: %s][edge: IPv6:%u][last seen: %u sec ago]",
		   ++num, macaddr_str(buf, list->mac_addr), list->sock.port,
		   now-list->last_seen);
    }
  }

  traceEvent(TRACE_NORMAL, "====================================");
}
#endif

/* *************************************************** */

static int keep_running;

#if defined(__linux__) || defined(WIN32)
#ifdef WIN32
BOOL WINAPI term_handler(DWORD sig)
#else
static void term_handler(int sig)
#endif
{
  static int called = 0;

  if(called) {
    traceEvent(TRACE_NORMAL, "Ok I am leaving now");
    _exit(0);
  } else {
    traceEvent(TRACE_NORMAL, "Shutting down...");
    called = 1;
  }

  keep_running = 0;
#ifdef WIN32
  return(TRUE);
#endif
}
#endif /* defined(__linux__) || defined(WIN32) */

/* *************************************************** */

/** Main program entry point from kernel. */
int main(int argc, char * const argv[]) {
  int rc;

	sn_init(&sss_node);

  if((argc >= 2) && (argv[1][0] != '-')) {
    rc = loadFromFile(argv[1], &sss_node);
    if(argc > 2)
      rc = loadFromCLI(argc, argv, &sss_node);
  } else if(argc > 1)
    rc = loadFromCLI(argc, argv, &sss_node);
  else
#ifdef WIN32
    /* Load from current directory */
    rc = loadFromFile("supernode.conf", &sss_node);
#else
    rc = -1;
#endif

  if(rc < 0)
    help();

#if defined(N2N_HAVE_DAEMON)
  if(sss_node.daemon) {
    setUseSyslog(1); /* traceEvent output now goes to syslog. */

    if(-1 == daemon(0, 0)) {
      traceEvent(TRACE_ERROR, "Failed to become daemon.");
      exit(-5);
    }
  }
#endif /* #if defined(N2N_HAVE_DAEMON) */

#ifndef WIN32
  if((getuid() == 0) || (getgid() == 0))
    traceEvent(TRACE_WARNING, "Running as root is discouraged");
#endif

  traceEvent(TRACE_DEBUG, "traceLevel is %d", getTraceLevel());

  sss_node.sock = open_socket(sss_node.lport, 1 /*bind ANY*/);
  if(-1 == sss_node.sock) {
    traceEvent(TRACE_ERROR, "Failed to open main socket. %s", strerror(errno));
    exit(-2);
  } else {
    traceEvent(TRACE_NORMAL, "supernode is listening on UDP %u (main)", sss_node.lport);
  }

  sss_node.mgmt_sock = open_socket(N2N_SN_MGMT_PORT, 0 /* bind LOOPBACK */);
  if(-1 == sss_node.mgmt_sock) {
    traceEvent(TRACE_ERROR, "Failed to open management socket. %s", strerror(errno));
    exit(-2);
  } else
    traceEvent(TRACE_NORMAL, "supernode is listening on UDP %u (management)", N2N_SN_MGMT_PORT);

  traceEvent(TRACE_NORMAL, "supernode started");

#ifdef __linux__
  signal(SIGTERM, term_handler);
  signal(SIGINT, term_handler);
  signal(SIGHUP, dump_registrations);
#endif
#ifdef WIN32
  SetConsoleCtrlHandler(term_handler, TRUE);
#endif

  keep_running = 1;
  return run_sn_loop(&sss_node, &keep_running);
}


