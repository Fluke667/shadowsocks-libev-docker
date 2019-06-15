
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



