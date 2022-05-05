# N2N

N2N is a light VPN software which make it easy to create virtual networks bypassing intermediate firewalls.

In order to start using N2N, two elements are required:

- A _supernode_: it allows edge nodes to announce and discover other nodes. It must have a port publicly accessible on internet.
- _edge_ nodes: the nodes which will be part of the virtual networks

A virtual network shared between multiple edge nodes in n2n is called a _community_. A single supernode can relay multiple communities and a single PC can be part of multiple communities at the same time. An encryption key can be used by the edge nodes to encrypt the packets within their community.

N2N tries to establish a direct P2P connection between the edge nodes when possible. When this is not possible (usually due to special NAT devices), the supernode is also used to relay the packets.

## Quick Setup

Some Linux distributions already provide n2n as a package so a simple `sudo apt install n2n` will do the work. Alternatively, up to date packages for most distributions are available on [ntop repositories](http://packages.ntop.org/).

On host1 run:

```sh
$ sudo edge -c mynetwork -k mysecretpass -a 192.168.100.1 -f -l supernode.ntop.org:7777
```

On host2 run:

```sh
$ sudo edge -c mynetwork -k mysecretpass -a 192.168.100.2 -f -l supernode.ntop.org:7777
```

Now the two hosts can ping each other.

**IMPORTANT** It is strongly advised to choose a custom community name (`-c`) and a secret encryption key (`-k`) in order to prevent other users to connect to your PC. For privacy and to reduce the above server load, it is also suggested to set up a custom supernode as explained below.

## Setting up a custom Supernode

You can create your own infrastructure by setting up a supernode on a public server (e.g. a VPS). You just need to open a single port (1234 in the example below) on your firewall (usually `iptables`).

1. Install the n2n package
2. Edit `/etc/n2n/supernode.conf` and add the following:
   ```
   -l=1234
   ```
3. Start the supernode service with `sudo systemctl start supernode`
4. Optionally enable supernode start on boot: `sudo systemctl enable supernode`

Now the supernode service should be up and running on port 1234. On your edge nodes you can now specify `-l your_supernode_ip:1234` to use it. All the edge nodes must use the same supernode.

## Routing the traffic

Reaching a remote network or tunneling all the internet traffic via n2n are two common tasks which require a proper routing setup. In this context, the `server` is the edge node which provides access to the remote network/internet, whereas the `client` is the connecting edge node.

In order to enable routing, the `server` must be configured as follows:

1. Add the `-r` option to the edge options to enable routing
2. Enable packet forwarding with `sudo sysctl -w net.ipv4.ip_forward=1`
3. Enable IP masquerading: `sudo iptables -t nat -A POSTROUTING -j MASQUERADE`

On the client side, the easiest way to configure routing is via the `-n` option. For example:

- In order to connect to the remote network `192.168.100.0/24`, use `-n 192.168.100.0/24:10.0.0.1`
- In order to tunnel all the internet traffic, use `-n 0.0.0.0/0:10.0.0.1`

10.0.0.1 is the IP address of the gateway to use to route the specified network. It should correspond to the IP address of the `server` within n2n. Multiple `-n` options can be specified.

As an alternative to the `-n` option, the `ip route` linux command can be manually used. See the [n2n_gateway.sh](doc/n2n_gateway.sh) script for an example. See also [Routing.md](doc/Routing.md) for other use cases and in depth explanation.

## Manual Compilation

On linux, compilation from source is straight forward:

```sh
./autogen.sh
./configure
make

# optionally install
make install
```

Parts of the code – especially Speck cipher and the header encryption – speedwise benefit
from compiler optimizations and platform features such as NEON, SSE and AVX. To enable, 
use `./configure CFLAGS="-O3 -march=native"` for configuration instead.

For Windows, check out [Windows.md](doc/Windows.md) for compilation and run instuctions.
For MacOS, check out [macOS.md](doc/macOS.md).

## Running edge as a service

edge can also be run as a service instead of cli:

1. Edit `/etc/n2n/edge.conf` with your custom options. See `/etc/n2n/edge.conf.sample`.
2. Start the service: `sudo systemctl start edge`
3. Optionally enable edge start on boot: `sudo systemctl enable edge`

You can run multiple edge service instances by creating `/etc/n2n/edge-instance1.conf` and
starting it with `sudo systemctl start edge@instance1`.

## IPv6 Support

N2N can tunnel IPv6 traffic into the virtual network but does not support
IPv6 for edge-to-supernode communication yet.

Check out [IPv6.md](https://github.com/ntop/n2n/blob/dev/doc/IPv6.md) for more information.

## Security considerations

n2n edge nodes use twofish encryption by default for compatibility reasons with existing versions.

Different encryption schemes are applied to the packet payload and to the header which
contains some metadata like the virtual MAC address of the edge nodes, their IP address and the community
name.

When encryption is enabled, the supernode will not be able to decrypt the traffic exchanged between
two edge nodes, but it will know that edge A is talking with edge B.

Recently AES encryption support has been implemented, which increases both security and performance,
so it is recommended to enable it on all the edge nodes that must have the -Ax value. When possible
(i.e. when n2n is compiled with OpenSSL 1.1) we recommend to use `-A3`.

A benchmark of the encryption methods is available when compiled from source with `tools/n2n-benchmark`.

Use `-H` on the edges to enable header encryption. Note, that header encryption is a per-community 
decision, i.e. _all_ edges of one community need to have it either enabled or disabled.  The supernode
can handle encrypted and unencrypted headers. As the key for header encryption is derived from the
community names, it requires the supernode to be used with fixed communities `-c <path>` 
parameter. Also, reuse of once-publically-used community names for header encryption is not recomended.

## Contribution

You can contribute to n2n in various ways:

- Update an [open issue](https://github.com/ntop/n2n/issues) or create a new one with detailed information
- Propose new features
- Improve the documentation
- Provide pull requests with enhancements

For details about the internals of n2n check out [Hacking guide](https://github.com/ntop/n2n/blob/dev/doc/HACKING).

## Related Projects

Here is a list of third-party projects connected to this repository.

- N2N for Android: [hin2n](https://github.com/switch-iot/hin2n)
- Docker images: [Docker Hub](https://hub.docker.com/r/supermock/supernode/)
- Go bindings, management daemons and CLIs for n2n edges and supernodes, Docker, Kubernetes & Helm Charts: [pojntfx/gon2n](https://pojntfx.github.io/gon2n/)

---

(C) 2007-2020 - ntop.org and contributors
