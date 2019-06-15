
### Shadowsocks over websocket (HTTP)

On your server

```sh
ss-server -c config.json -p 80 --plugin v2ray-plugin --plugin-opts "server"
```

On your client

```sh
ss-local -c config.json -p 80 --plugin v2ray-plugin
```

### Shadowsocks over websocket (HTTPS)

On your server

```sh
ss-server -c config.json -p 443 --plugin v2ray-plugin --plugin-opts "server;tls;host=mydomain.me"
```

On your client

```sh
ss-local -c config.json -p 443 --plugin v2ray-plugin --plugin-opts "tls;host=mydomain.me"
```

### Shadowsocks over quic

On your server

```sh
ss-server -c config.json -p 443 --plugin v2ray-plugin --plugin-opts "server;mode=quic;host=mydomain.me"
```

On your client

```sh
ss-local -c config.json -p 443 --plugin v2ray-plugin --plugin-opts "mode=quic;host=mydomain.me"
```

## Enable v2ray-plugin

docker run -d \
-e "ARGS=--plugin v2ray-plugin --plugin-opts server;mode=quic;host=yourdomain.com" \
-e PASSWORD=YourPassword \
-v /home/username/.acme.sh:/root/.acme.sh
--name=shadowsocks-libev \
-p 8388:8388/tcp \
-p 8388:8388/udp \
--restart=always \
fluke667/shadowsocks-libev-docker

## Enable v2ray-plugin with TLS mode and enable UDP relay:

docker run -d \
-e "ARGS=--plugin v2ray-plugin --plugin-opts server;tls;host=yourdomain.com -u" \
-e PASSWORD=YourPassword \
-v /home/username/.acme.sh:/root/.acme.sh
--name=shadowsocks-libev \
-p 8388:8388/tcp \
-p 8388:8388/udp \
--restart=always \
fluke667/shadowsocks-libev-docker



ss-server(1)
============

NAME
----
ss-server - shadowsocks server, libev port

SYNOPSIS
--------
*ss-server*
 [-uUv] [-h|--help]
 [-s <server_host>] [-p <server_port>] [-l <local_port>]
 [-k <password>] [-m <encrypt_method>] [-f <pid_file>]
 [-t <timeout>] [-c <config_file>] [-i <interface>]
 [-a <user_name>] [-d <addr>] [-n <nofile>]
 [-b <local_address>] [--fast-open] [--reuse-port]
 [--mptcp] [--acl <acl_config>] [--mtu <MTU>] [--no-delay]
 [--manager-address <path_to_unix_domain>]
 [--plugin <plugin_name>] [--plugin-opts <plugin_options>]
 [--password <password>] [--key <key_in_base64>]

DESCRIPTION
-----------
*Shadowsocks-libev* is a lightweight and secure socks5 proxy.
It is a port of the original shadowsocks created by clowwindy.
*Shadowsocks-libev* is written in pure C and takes advantage of libev to
achieve both high performance and low resource consumption.

*Shadowsocks-libev* consists of five components.
`ss-server`(1) runs on a remote server to provide secured tunnel service.
For more information, check out `shadowsocks-libev`(8).

OPTIONS
-------
-s <server_host>::
Set the server's hostname or IP.

-p <server_port>::
Set the server's port number.

-k <password>::
--password <password>::
Set the password. The server and the client should use the same password.

--key <key_in_base64>::
Set the key directly. The key should be encoded with URL-safe Base64.

-m <encrypt_method>::
Set the cipher.
+
*Shadowsocks-libev* accepts 23 different ciphers:
+
```txt
rc4
rc4-md5
rc2-cfb
des-cfb
idea-cfb
seed-cfb
cast5-cfb
bf-cfb
aes-128-gcm ** Recommend **
aes-192-gcm ** Recommend **
aes-256-gcm ** Recommend **
aes-128-cfb
aes-192-cfb
aes-256-cfb
aes-128-ctr
aes-192-ctr
aes-256-ctr
camellia-128-cfb
camellia-192-cfb
camellia-256-cfb,
chacha20-ietf-poly1305 ** Recommend **
salsa20
chacha20
chacha20-ietf.
```
+
If built with PolarSSL or custom OpenSSL libraries, some of
these ciphers may not work.

-a <user_name>::
Run as a specific user.

-f <pid_file>::
Start shadowsocks as a daemon with specific pid file.

-t <timeout>::
Set the socket timeout in seconds. The default value is 60.

-c <config_file>::
Use a configuration file.
+
Refer to `shadowsocks-libev`(8) 'CONFIG FILE' section for more details.

-n <number>::
Specify max number of open files.
+
Only available on Linux.

-i <interface>::
Send traffic through specific network interface.
+
For example, there are three interfaces in your device,
which is lo (127.0.0.1), eth0 (192.168.0.1) and eth1 (192.168.0.2).
Meanwhile, you configure `ss-server` to listen on 0.0.0.0:8388 and bind to eth1.
That results the traffic go out through eth1, but not lo nor eth0.
This option is useful to control traffic in multi-interface environment.

-b <local_address>::
Specify the local address to use while this server is making outbound 
connections to remote servers on behalf of the clients.

-u::
Enable UDP relay.

-U::
Enable UDP relay and disable TCP relay.

-6::
Resovle hostname to IPv6 address first.

-d <addr>::
Setup name servers for internal DNS resolver (libc-ares).
The default server is fetched from '/etc/resolv.conf'.

--fast-open::
Enable TCP fast open.
+
Only available with Linux kernel > 3.7.0.

--reuse-port::
Enable port reuse.
+
Only available with Linux kernel > 3.9.0.

--no-delay::
Enable TCP_NODELAY.

--acl <acl_config>::
Enable ACL (Access Control List) and specify config file.

--manager-address <path_to_unix_domain>::
Specify UNIX domain socket address for the communication between ss-manager(1) and ss-server(1).
+
Only available in server and manager mode.

--mtu <MTU>::
Specify the MTU of your network interface.

--mptcp::
Enable Multipath TCP.
+
Only available with MPTCP enabled Linux kernel.

--plugin <plugin_name>::
Enable SIP003 plugin. (Experimental)

--plugin-opts <plugin_options>::
Set SIP003 plugin options. (Experimental)

-v::
Enable verbose mode.

-h|--help::
Print help message.

EXAMPLE
-------
It is recommended to use a config file when starting `ss-server`(1).

The config file is written in JSON and is easy to edit.
Check out the 'SEE ALSO' section for the default path of config file.

....
# Start the ss-server
ss-server -c /etc/shadowsocks-libev/config.json
....

### Issue a cert for TLS and QUIC

v2ray-plugin will look for TLS certificates signed by [acme.sh](https://github.com/Neilpang/acme.sh) by default.
Here's some sample commands for issuing a certificate using CloudFlare.
You can find commands for issuing certificates for other DNS providers at acme.sh.

```sh
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --issue --dns dns_cf -d mydomain.me
```

Alternatively, you can specify path to your certificates using option `cert` and `key`.
