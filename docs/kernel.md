## Linux kernel parameters explained

### Wireguard support
CONFIG_NET for basic networking support
CONFIG_INET for basic IP support
CONFIG_NET_UDP_TUNNEL for sending and receiving UDP packets
CONFIG_WIREGUARD controls whether or not WireGuard is built (as a module, as built-in, or not at all)
CONFIG_WIREGUARD_DEBUG turns on verbose debug messages
CONFIG_NF_CONNTRACK - For determining the source address when constructing ICMP packets.
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT - For ratelimiting when under DoS attacks.
CONFIG_IP6_NF_IPTABLES - Only if using CONFIG_IPV6 for ratelimiting when under DoS attacks.
CONFIG_CRYPTO_BLKCIPHER - For doing scatter-gather I/O.
CONFIG_PADATA - For parallel crypto

### Iproute2 support
CONFIG_NETFILTER_NETLINK=y 
CONFIG_NETFILTER_NETLINK_QUEUE=y 
CONFIG_NETFILTER_NETLINK_LOG=y 
CONFIG_NF_CT_NETLINK=y 
CONFIG_SCSI_NETLINK=y 
CONFIG_IP_ADVANCED_ROUTER=y 
CONFIG_NET_SCH_INGRESS=y 
CONFIG_NET_SCHED=y 
CONFIG_IP_MULTIPLE_TABLES=y 
CONFIG_NETFILTER_XT_TARGET_MARK=y

